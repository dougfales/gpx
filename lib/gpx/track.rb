# frozen_string_literal: true

module GPX
  # In GPX, a single Track can hold multiple Segments, each of which hold
  # multiple points (in this library, those points are instances of
  # TrackPoint).  Each instance of this class has its own meta-data, including
  # low point, high point, and distance.  Of course, each track references an
  # array of the segments that comprise it, but additionally each track holds
  # a reference to all of its points as one big array called "points".
  class Track < Base
    attr_reader :points, :bounds, :lowest_point, :highest_point, :distance, :moving_duration
    attr_accessor :segments, :name, :gpx_file, :description, :comment

    # Initialize a track from a XML::Node, or, if no :element option is
    # passed, initialize a blank Track object.
    def initialize(opts = {})
      super()
      @gpx_file = opts[:gpx_file]
      @segments = []
      @points = []
      reset_meta_data

      return unless opts[:element]

      trk_element = opts[:element]
      @name = (
      begin
        trk_element.at('name').inner_text
      rescue StandardError
        ''
      end)
      @comment = (
      begin
        trk_element.at('cmt').inner_text
      rescue StandardError
        ''
      end)
      @description = (
      begin
        trk_element.at('desc').inner_text
      rescue StandardError
        ''
      end)
      trk_element.search('trkseg').each do |seg_element|
        seg = Segment.new(element: seg_element, track: self, gpx_file: @gpx_file)
        append_segment(seg)
      end
    end

    # Append a segment to this track, updating its meta data along the way.
    def append_segment(seg)
      return if seg.points.empty?

      update_meta_data(seg)
      @segments << seg
    end

    # Returns true if the given time occurs within any of the segments of this track.
    def contains_time?(time)
      segments.each do |seg|
        return true if seg.contains_time?(time)
      end
      false
    end

    # Finds the closest point (to "time") within this track.  Useful for
    # correlating things like pictures, video, and other events, if you are
    # working with a timestamp.
    def closest_point(time)
      segment = segments.select { |s| s.contains_time?(time) }
      segment.first
    end

    # Removes all points outside of a given area and updates the meta data.
    # The "area" paremeter is usually a Bounds object.
    def crop(area)
      reset_meta_data
      segments.each do |seg|
        seg.crop(area)
        update_meta_data(seg) unless seg.empty?
      end
      segments.delete_if(&:empty?)
    end

    # Deletes all points within a given area and updates the meta data.
    def delete_area(area)
      reset_meta_data
      segments.each do |seg|
        seg.delete_area(area)
        update_meta_data(seg) unless seg.empty?
      end
      segments.delete_if(&:empty?)
    end

    # Returns true if this track has no points in it.  This should return
    # true even when the track has empty segments.
    def empty?
      (points.nil? || points.size.zero?)
    end

    # Prints out a friendly summary of this track (sans points).  Useful for
    # debugging and sanity checks.

    def to_s
      result = "Track \n"
      result << "\tName: #{name}\n"
      result << "\tComment: #{comment}\n"
      result << "\tDescription: #{description}\n"
      result << "\tSize: #{points.size} points\n"
      result << "\tSegments: #{segments.size} \n"
      result << "\tDistance: #{distance} km\n"
      result << "\tMoving duration: #{moving_duration} km\n"
      result << "\tLowest Point: #{lowest_point.elevation} \n"
      result << "\tHighest Point: #{highest_point.elevation}\n "
      result << "\tBounds: #{bounds}"
      result
    end

    def recalculate_distance
      @distance = 0
      @segments.each do |seg|
        @distance += seg.distance
      end
    end

    protected

    def update_meta_data(seg)
      @lowest_point = seg.lowest_point if @lowest_point.nil? || (seg.lowest_point.elevation < @lowest_point.elevation)
      @highest_point = seg.highest_point if @highest_point.nil? || (seg.highest_point.elevation > @highest_point.elevation)
      @bounds.add(seg.bounds)
      @distance += seg.distance
      @moving_duration += seg.duration
      @points.concat(seg.points)
    end

    def reset_meta_data
      @bounds = Bounds.new
      @highest_point = nil
      @lowest_point = nil
      @distance = 0.0
      @moving_duration = 0.0
      @points = []
    end
  end
end
