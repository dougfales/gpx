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

   # A segment is the basic container in a GPX file.  A Segment contains points
   # (in this lib, they're called TrackPoints).  A Track contains Segments.  An
   # instance of Segment knows its highest point, lowest point, earliest and
   # latest points, distance, and bounds.
   class Segment < Base

      attr_reader :earliest_point, :latest_point, :bounds, :highest_point, :lowest_point, :distance
      attr_accessor :points, :track 

      # If a REXML::Element object is passed-in, this will initialize a new
      # Segment based on its contents.  Otherwise, a blank Segment is created.
      def initialize(opts = {})
         @track = opts[:track]
         @points = []
         @earliest_point = nil
         @latest_point = nil
         @highest_point = nil
         @lowest_point = nil
         @distance = 0.0
         @bounds = Bounds.new
         if(opts[:element])
            segment_element = opts[:element]
            last_pt = nil
            unless segment_element.is_a?(Text)
               XPath.each(segment_element, "child::trkpt") do |trkpt| 
                  pt = TrackPoint.new(:element => trkpt, :segment => self)  
                  unless pt.time.nil?
                     @earliest_point = pt if(@earliest_point.nil? or pt.time < @earliest_point.time)
                     @latest_point   = pt if(@latest_point.nil? or pt.time > @latest_point.time)
                  end
                  unless pt.elevation.nil?
                     @lowest_point   = pt if(@lowest_point.nil? or pt.elevation < @lowest_point.elevation)
                     @highest_point  = pt if(@highest_point.nil? or pt.elevation > @highest_point.elevation)
                  end
                  @bounds.min_lat = pt.lat if pt.lat < @bounds.min_lat
                  @bounds.min_lon = pt.lon if pt.lon < @bounds.min_lon
                  @bounds.max_lat = pt.lat if pt.lat > @bounds.max_lat
                  @bounds.max_lon = pt.lon if pt.lon > @bounds.max_lon

                  @distance += haversine_distance(last_pt, pt) unless last_pt.nil?

                  @points << pt
                  last_pt  = pt
               end
            end
         end
      end

      # Tack on a point to this Segment.  All meta-data will be updated.
      def append_point(pt)
         last_pt = @points[-1]
         @earliest_point = pt if(@earliest_point.nil? or pt.time < @earliest_point.time)
         @latest_point   = pt if(@latest_point.nil? or pt.time > @latest_point.time)
         @lowest_point   = pt if(@lowest_point.nil? or pt.elevation < @lowest_point.elevation)
         @highest_point  = pt if(@highest_point.nil? or pt.elevation > @highest_point.elevation)
         @bounds.min_lat = pt.lat if pt.lat < @bounds.min_lat
         @bounds.min_lon = pt.lon if pt.lon < @bounds.min_lon
         @bounds.max_lat = pt.lat if pt.lat > @bounds.max_lat
         @bounds.max_lon = pt.lon if pt.lon > @bounds.max_lon
         @distance += haversine_distance(last_pt, pt) unless last_pt.nil?
         @points << pt
      end

      # Returns true if the given time is within this Segment.
      def contains_time?(time)
         (time >= @earliest_point.time and time <= @latest_point.time) rescue false
      end

      # Finds the closest point in time to the passed-in time argument.  Useful
      # for matching up time-based objects (photos, video, etc) with a
      # geographic location.
      def closest_point(time)
         find_closest(points, time)
      end

      # Deletes all points within this Segment that lie outside of the given
      # area (which should be a Bounds object).
      def crop(area)
         delete_if { |pt| not area.contains?(pt) }
      end

      # Deletes all points in this Segment that lie within the given area.
      def delete_area(area)
         delete_if{ |pt| area.contains?(pt) }
      end

      # A handy method that deletes points based on a block that is passed in.
      # If the passed-in block returns true when given a point, then that point
      # is deleted.  For example:
      #         delete_if{ |pt| area.contains?(pt) }
      def delete_if
         reset_meta_data
         keep_points = []
         last_pt = nil
         points.each do |pt| 
            unless yield(pt)
               keep_points << pt
               update_meta_data(pt, last_pt)
               last_pt = pt
            end
         end
         @points = keep_points
      end

      # Returns true if this Segment has no points.
      def empty?
         (points.nil? or (points.size == 0))
      end

      # Converts this Segment to a REXML::Element object.
      def to_xml
         seg = Element.new('trkseg')
         points.each { |pt| seg.elements << pt.to_xml }
         seg
      end

      # Prints out a nice summary of this Segment.
      def to_s
         result = "Track Segment\n"
         result << "\tSize: #{points.size} points\n"
         result << "\tDistance: #{distance} km\n"
         result << "\tEarliest Point: #{earliest_point.time.to_s} \n"
         result << "\tLatest Point: #{latest_point.time.to_s} \n"
         result << "\tLowest Point: #{lowest_point.elevation} \n"
         result << "\tHighest Point: #{highest_point.elevation}\n "
         result << "\tBounds: #{bounds.to_s}"
         result
      end

      protected
      def find_closest(pts, time)
         return pts.first if pts.size == 1
         midpoint = pts.size/2
         if pts.size == 2
            diff_1 = pts[0].time - time
            diff_2 = pts[1].time - time
            return (diff_1 < diff_2 ? pts[0] : pts[1])
         end
         if time >= pts[midpoint].time and time <= pts[midpoint+1].time

            return pts[midpoint]

         elsif(time <= pts[midpoint].time)
            return find_closest(pts[0..midpoint], time)
         else
            return find_closest(pts[(midpoint+1)..-1], time)
         end
      end

      RADIUS = 6371; # earth's mean radius in km

      # Calculate the Haversine distance between two points. This is the method
      # the library uses to calculate the cumulative distance of GPX files. 
      def haversine_distance(p1, p2)
         d_lat = p2.latr - p1.latr;
         d_lon = p2.lonr - p1.lonr;
         a = Math.sin(d_lat/2) * Math.sin(d_lat/2) + Math.cos(p1.latr) * Math.cos(p2.latr) * Math.sin(d_lon/2) * Math.sin(d_lon/2);
         c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
         d = RADIUS * c;
         return d;
      end

      # Calculate the plain Pythagorean difference between two points.  Not currently used.
      def pythagorean_distance(p1, p2)
         Math.sqrt((p2.latr - p1.latr)**2 + (p2.lonr - p1.lonr)**2)
      end

      # Calculates the distance between two points using the Law of Cosines formula.  Not currently used.
      def law_of_cosines_distance(p1, p2)
         (Math.acos(Math.sin(p1.latr)*Math.sin(p2.latr) + Math.cos(p1.latr)*Math.cos(p2.latr)*Math.cos(p2.lonr-p1.lonr)) * RADIUS)
      end

      def reset_meta_data
         @earliest_point = nil
         @latest_point = nil
         @highest_point = nil
         @lowest_point = nil
         @distance = 0.0
         @bounds = Bounds.new
      end

      def update_meta_data(pt, last_pt)
         unless pt.time.nil?
            @earliest_point = pt if(@earliest_point.nil? or pt.time < @earliest_point.time)
            @latest_point   = pt if(@latest_point.nil? or pt.time > @latest_point.time)
         end
         unless pt.elevation.nil?
            @lowest_point   = pt if(@lowest_point.nil? or pt.elevation < @lowest_point.elevation)
            @highest_point  = pt if(@highest_point.nil? or pt.elevation > @highest_point.elevation)
         end
         @bounds.add(pt)
         @distance += haversine_distance(last_pt, pt) unless last_pt.nil?
      end

   end

end
