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

    # If a XML::Node object is passed-in, this will initialize a new
    # Segment based on its contents.  Otherwise, a blank Segment is created.
    def initialize(opts = {})
      @gpx_file = opts[:gpx_file]
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
        if segment_element.is_a?(Nokogiri::XML::Node)
          segment_element.search("trkpt").each do |trkpt|
            pt = TrackPoint.new(:element => trkpt, :segment => self, :gpx_file => @gpx_file)
            append_point(pt)
          end
        end
      end
    end

    # Tack on a point to this Segment.  All meta-data will be updated.
    def append_point(pt)
      last_pt = @points[-1]
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

    def find_point_by_time_or_offset(indicator)
      if indicator.nil?
        return nil
      elsif indicator.is_a?(Integer)
        return closest_point(@earliest_point.time + indicator)
      elsif(indicator.is_a?(Time))
        return closest_point(indicator)
      else
        raise Exception, "find_end_point_by_time_or_offset requires an argument of type Time or Integer"
      end
    end
  
    # smooths the location data in the segment (by recalculating the location as an average of 20 neighbouring points.  Useful for removing noise from GPS traces.
    def smooth_location_by_average(opts={})
      seconds_either_side = opts[:averaging_window] || 20

      #calculate the first and last points to which the smoothing should be applied
      earliest = (find_point_by_time_or_offset(opts[:start]) || @earliest_point).time
      latest = (find_point_by_time_or_offset(opts[:end]) || @latest_point).time

      tmp_points = []

      @points.each do |point|
        if point.time > latest || point.time < earliest
          tmp_points.push point #add the point unaltered
          next 
        end
        lat_av = 0.to_f
        lon_av = 0.to_f
        alt_av = 0.to_f
        n = 0
        # k ranges from the time of the current point +/- 20s 
        (-1*seconds_either_side..seconds_either_side).each do |k|
          # find the point nearest to the time offset indicated by k
          contributing_point = closest_point(point.time + k)
          #sum up the contributions to the average
          lat_av += contributing_point.lat
          lon_av += contributing_point.lon
          alt_av += contributing_point.elevation
          n += 1
        end
        # calculate the averages
        tmp_point = point.clone
        tmp_point.lon = ((lon_av) / n).round(7)
        tmp_point.elevation = ((alt_av) / n).round(2)
        tmp_point.lat = ((lat_av) / n).round(7)
        tmp_points.push tmp_point
      end
      last_pt = nil
      @distance = 0
      @points.clear
      reset_meta_data
      #now commit the averages back and recalculate the distances
      tmp_points.each do |point|
        append_point(point)
      end
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

    # Calculate the Haversine distance between two points. This is the method
    # the library uses to calculate the cumulative distance of GPX files.
    def haversine_distance(p1, p2)
      p1.haversine_distance_from(p2)
    end

    # Calculate the plain Pythagorean difference between two points.  Not currently used.
    def pythagorean_distance(p1, p2)
      p1.pythagorean_distance_from(p2)
    end

    # Calculates the distance between two points using the Law of Cosines formula.  Not currently used.
    def law_of_cosines_distance(p1, p2)
      p1.law_of_cosines_distance_from(p2)
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
