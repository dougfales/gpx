# frozen_string_literal: true

module GPX
  # A segment is the basic container in a GPX file.  A Segment contains points
  # (in this lib, they're called TrackPoints).  A Track contains Segments.  An
  # instance of Segment knows its highest point, lowest point, earliest and
  # latest points, distance, and bounds.
  class Segment < Base
    attr_reader :earliest_point, :latest_point, :bounds, :highest_point, :lowest_point, :distance, :duration
    attr_accessor :points, :track

    # If a XML::Node object is passed-in, this will initialize a new
    # Segment based on its contents.  Otherwise, a blank Segment is created.
    def initialize(opts = {})
      super()
      @gpx_file = opts[:gpx_file]
      @track = opts[:track]
      @points = []
      @earliest_point = nil
      @latest_point = nil
      @highest_point = nil
      @lowest_point = nil
      @distance = 0.0
      @duration = 0.0
      @bounds = Bounds.new

      segment_element = opts[:element]
      return unless segment_element.is_a?(Nokogiri::XML::Node)

      segment_element.search('trkpt').each do |trkpt|
        pt = TrackPoint.new(element: trkpt, segment: self, gpx_file: @gpx_file)
        append_point(pt)
      end
    end

    # Tack on a point to this Segment.  All meta-data will be updated.
    def append_point(pt)
      last_pt = @points[-1]
      if pt.time
        @earliest_point = pt if @earliest_point.nil? || (@earliest_point.time && pt.time < @earliest_point.time)
        @latest_point = pt if @latest_point.nil? || (@latest_point.time && pt.time > @latest_point.time)
      else
        # when no time information in data, we consider the points are ordered
        @earliest_point = @points[0]
        @latest_point = pt
      end

      if pt.elevation
        @lowest_point = pt if @lowest_point.nil? || (pt.elevation < @lowest_point.elevation)
        @highest_point = pt if @highest_point.nil? || (pt.elevation > @highest_point.elevation)
      end
      @bounds.min_lat = pt.lat if pt.lat < @bounds.min_lat
      @bounds.min_lon = pt.lon if pt.lon < @bounds.min_lon
      @bounds.max_lat = pt.lat if pt.lat > @bounds.max_lat
      @bounds.max_lon = pt.lon if pt.lon > @bounds.max_lon
      if last_pt
        @distance += haversine_distance(last_pt, pt)
        @duration += pt.time - last_pt.time if pt.time && last_pt.time
      end
      @points << pt
    end

    # Returns true if the given time is within this Segment.
    def contains_time?(time)
      ((time >= @earliest_point.time) && (time <= @latest_point.time))
    rescue StandardError
      false
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
      delete_if { |pt| !area.contains?(pt) }
    end

    # Deletes all points in this Segment that lie within the given area.
    def delete_area(area)
      delete_if { |pt| area.contains?(pt) }
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
        next if yield(pt)

        keep_points << pt
        update_meta_data(pt, last_pt)
        last_pt = pt
      end
      @points = keep_points
    end

    # Returns true if this Segment has no points.
    def empty?
      (points.nil? || points.empty?)
    end

    # Prints out a nice summary of this Segment.
    def to_s
      result = "Track Segment\n"
      result << "\tSize: #{points.size} points\n"
      result << "\tDistance: #{distance} km\n"
      result << "\tEarliest Point: #{earliest_point.time} \n"
      result << "\tLatest Point: #{latest_point.time} \n"
      result << "\tLowest Point: #{lowest_point.elevation} \n"
      result << "\tHighest Point: #{highest_point.elevation}\n "
      result << "\tBounds: #{bounds}"
      result
    end

    def find_point_by_time_or_offset(indicator)
      if indicator.nil?
        nil
      elsif indicator.is_a?(Integer)
        closest_point(@earliest_point.time + indicator)
      elsif indicator.is_a?(Time)
        closest_point(indicator)
      else
        raise ArgumentError, 'find_end_point_by_time_or_offset requires an argument of type Time or Integer'
      end
    end

    # smooths the location data in the segment (by recalculating the location as an average of 20 neighbouring points.  Useful for removing noise from GPS traces.
    def smooth_location_by_average(opts = {})
      seconds_either_side = opts[:averaging_window] || 20

      # calculate the first and last points to which the smoothing should be applied
      earliest = (find_point_by_time_or_offset(opts[:start]) || @earliest_point).time
      latest = (find_point_by_time_or_offset(opts[:end]) || @latest_point).time

      tmp_points = []

      @points.each do |point|
        if point.time > latest || point.time < earliest
          tmp_points.push point # add the point unaltered
          next
        end
        lat_av = 0.to_f
        lon_av = 0.to_f
        alt_av = 0.to_f
        n = 0
        # k ranges from the time of the current point +/- 20s
        (-1 * seconds_either_side..seconds_either_side).each do |k|
          # find the point nearest to the time offset indicated by k
          contributing_point = closest_point(point.time + k)
          # sum up the contributions to the average
          lat_av += contributing_point.lat
          lon_av += contributing_point.lon
          alt_av += contributing_point.elevation
          n += 1
        end
        # calculate the averages
        tmp_point = point.clone
        tmp_point.lon = (lon_av / n).round(7)
        tmp_point.elevation = (alt_av / n).round(2)
        tmp_point.lat = (lat_av / n).round(7)
        tmp_points.push tmp_point
      end
      @points.clear
      reset_meta_data
      # now commit the averages back and recalculate the distances
      tmp_points.each do |point|
        append_point(point)
      end
    end

    protected

    def find_closest(pts, time)
      return pts.first if pts.size == 1

      midpoint = pts.size / 2
      if pts.size == 2
        diff_1 = pts[0].time - time
        diff_2 = pts[1].time - time
        return (diff_1 < diff_2 ? pts[0] : pts[1])
      end
      if (time >= pts[midpoint].time) && (time <= pts[midpoint + 1].time)
        pts[midpoint]
      elsif time <= pts[midpoint].time
        find_closest(pts[0..midpoint], time)
      else
        find_closest(pts[(midpoint + 1)..-1], time)
      end
    end

    # Calculate the Haversine distance between two points. This is the method
    # the library uses to calculate the cumulative distance of GPX files.
    def haversine_distance(p1, p2)
      p1.haversine_distance_from(p2)
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
      @duration = 0.0
      @bounds = Bounds.new
    end

    def update_meta_data(pt, last_pt)
      if pt.time
        @earliest_point = pt if @earliest_point.nil? || (pt.time < @earliest_point.time)
        @latest_point = pt if @latest_point.nil? || (pt.time > @latest_point.time)
      else
        # when no time information in data, we consider the points are ordered
        @earliest_point = @points[0]
        @latest_point = @points[-1]
      end

      if pt.elevation
        @lowest_point = pt if @lowest_point.nil? || (pt.elevation < @lowest_point.elevation)
        @highest_point = pt if @highest_point.nil? || (pt.elevation > @highest_point.elevation)
      end
      @bounds.add(pt)

      return unless last_pt

      @distance += haversine_distance(last_pt, pt)
      @duration += pt.time - last_pt.time if pt.time && last_pt.time
    end
  end
end
