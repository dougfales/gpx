#--
# Copyright (c) 2006  Doug Fales 
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
module GPX
   class GPXFile < Base
      attr_reader :tracks, :routes, :waypoints, :bounds, :lowest_point, :highest_point, :distance, :duration, :average_speed


      # This initializer can be used to create a new GPXFile from an existing
      # file or to create a new GPXFile instance with no data (so that you can
      # add tracks and points and write it out to a new file later).
      # To read an existing GPX file, do this:
      #         gpx_file = GPXFile.new(:gpx_file => 'mygpxfile.gpx')
      #         puts "Speed: #{gpx_file.average_speed}"
      #         puts "Duration: #{gpx_file.duration}"
      #         puts "Bounds: #{gpx_file.bounds}"
      #
      # To create a new blank GPXFile instance:
      #         gpx_file = GPXFile.new
      # Note that you can pass in any instance variables to this form of the initializer, including Tracks or Segments:
      #         some_track = get_track_from_csv('some_other_format.csv')
      #         gpx_file = GPXFile.new(:tracks => [some_track])
      #
      def initialize(opts = {}) 
         @duration = 0
         if(opts[:gpx_file])
            gpx_file = opts[:gpx_file]
            case gpx_file
            when String
               gpx_file = File.open(gpx_file)
            end
            reset_meta_data
            @xml = Document.new(gpx_file, :ignore_whitespace_nodes => :all)

            bounds_element = (XPath.match(@xml, "/gpx/metadata/bounds").first rescue nil)
            if bounds_element
               @bounds.min_lat = bounds_element.attributes["min_lat"].to_f
               @bounds.min_lon = bounds_element.attributes["min_lon"].to_f
               @bounds.max_lat = bounds_element.attributes["max_lat"].to_f
               @bounds.max_lon = bounds_element.attributes["max_lon"].to_f
            else
               get_bounds = true
            end

            @tracks = XPath.match(@xml, "/gpx/trk").collect do |trk| 
               trk = Track.new(:element => trk, :gpx_file => self) 
               update_meta_data(trk, get_bounds)
               trk
            end
            @waypoints = XPath.match(@xml, "/gpx/wpt").collect { |wpt| Waypoint.new(:element => wpt, :gpx_file => self) }
            @routes =    XPath.match(@xml, "/gpx/rte").collect { |rte| Route.new(:element => rte, :gpx_file => self) }

            @tracks.delete_if { |t| t.empty? }

            calculate_duration
         else
            reset_meta_data
            opts.each { |attr_name, value| instance_variable_set("@#{attr_name.to_s}", value) }
            unless(@tracks.nil? or @tracks.size.zero?)
               @tracks.each { |trk| update_meta_data(trk) }
               calculate_duration
            end
         end
      end

      # Returns the distance, in kilometers, meters, or miles, of all of the
      # tracks and segments contained in this GPXFile.
      def distance(opts = { :units => 'kilometers' })
         case opts[:units]
         when /kilometers/i
            return @distance 
         when /meters/i
            return (@distance * 1000)
         when /miles/i
            return (@distance * 0.62)
         end
      end

      # Returns the average speed, in km/hr, meters/hr, or miles/hr, of this
      # GPXFile.  The calculation is based on the total distance divided by the
      # total duration of the entire file.  
      def average_speed(opts = { :units => 'kilometers' })
         case opts[:units]
         when /kilometers/i
            return @distance / (@duration/3600.0)
         when /meters/i
            return (@distance * 1000) /  (@duration/3600.0)
         when /miles/i
            return (@distance * 0.62) / (@duration/3600.0)
         end
      end

      # Crops any points falling within a rectangular area.  Identical to the
      # delete_area method in every respect except that the points outside of
      # the given area are deleted.  Note that this method automatically causes
      # the meta data to be updated after deletion.
      def crop(area)
         reset_meta_data
         keep_tracks = []
         tracks.each do |trk| 
            trk.crop(area) 
            unless trk.empty?
               update_meta_data(trk)
               keep_tracks << trk 
            end
         end
         @tracks = keep_tracks
         routes.each { |rte| rte.crop(area) }
         waypoints.each { |wpt| wpt.crop(area) }
      end

      # Deletes any points falling within a rectangular area.  The "area"
      # parameter is usually an instance of the Bounds class.  Note that this
      # method cascades into similarly named methods of subordinate classes
      # (i.e. Track, Segment), which means, if you want the deletion to apply
      # to all the data, you only call this one (and not the one in Track or
      # Segment classes).  Note that this method automatically causes the meta
      # data to be updated after deletion.
      def delete_area(area)
         reset_meta_data
         keep_tracks = []
         tracks.each do |trk| 
            trk.delete_area(area) 
            unless trk.empty?
               update_meta_data(trk)
               keep_tracks << trk 
            end
         end
         @tracks =  keep_tracks
         routes.each { |rte| rte.delete_area(area) }
         waypoints.each { |wpt| wpt.delete_area(area) }
      end

      # Resets the meta data for this GPX file.  Meta data includes the bounds,
      # the high and low points, and the distance.  
      def reset_meta_data
         @bounds = Bounds.new
         @highest_point = nil
         @lowest_point = nil
         @distance = 0.0
      end

      # Updates the meta data for this GPX file.  Meta data includes the
      # bounds, the high and low points, and the distance.  This is useful when
      # you modify the GPX data (i.e. by adding or deleting points) and you
      # want the meta data to accurately reflect the new data.
      def update_meta_data(trk, get_bounds = true)
         @lowest_point   = trk.lowest_point if(@lowest_point.nil? or trk.lowest_point.elevation < @lowest_point.elevation)
         @highest_point  = trk.highest_point if(@highest_point.nil? or trk.highest_point.elevation > @highest_point.elevation)
         @bounds.add(trk.bounds) if get_bounds
         @distance += trk.distance
      end

      # Serialize the current GPXFile to a gpx file named <filename>.
      # If the file does not exist, it is created.  If it does exist, it is overwritten.
      def write(filename)

         doc = Document.new
         gpx_elem = Element.new('gpx')
         doc.add(gpx_elem)
         gpx_elem.attributes['xmlns:xsi'] = "http://www.w3.org/2001/XMLSchema-instance" 
         gpx_elem.attributes['xmlns'] = "http://www.topografix.com/GPX/1/1" 
         gpx_elem.attributes['version'] = "1.1" 
         gpx_elem.attributes['creator'] = "GPX RubyGem 0.1 Copyright 2006 Doug Fales -- http://walkingboss.com" 
         gpx_elem.attributes['xsi:schemaLocation'] = "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"

         meta_data_elem = Element.new('metadata')
         name_elem = Element.new('name')
         name_elem.text = File.basename(filename)
         meta_data_elem.elements << name_elem

         time_elem = Element.new('time')
         time_elem.text = Time.now.xmlschema
         meta_data_elem.elements << time_elem

         meta_data_elem.elements << bounds.to_xml

         gpx_elem.elements << meta_data_elem

         tracks.each    { |t|   gpx_elem.add_element t.to_xml } unless tracks.nil?
         waypoints.each { |w| gpx_elem.add_element w.to_xml } unless waypoints.nil?
         routes.each    { |r| gpx_elem.add_element r.to_xml } unless routes.nil?

         File.open(filename, 'w') { |f| doc.write(f) }
      end

      private 

      # Calculates and sets the duration attribute by subtracting the time on
      # the very first point from the time on the very last point.
      def calculate_duration
         @duration = 0
         if(@tracks.nil? or @tracks.size.zero? or @tracks[0].segments.nil? or @tracks[0].segments.size.zero?)
            return @duration
         end
         @duration = (@tracks[-1].segments[-1].points[-1].time - @tracks.first.segments.first.points.first.time)
      rescue
         @duration = 0
      end


   end
end
