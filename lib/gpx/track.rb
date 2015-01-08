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
  # In GPX, a single Track can hold multiple Segments, each of which hold
  # multiple points (in this library, those points are instances of
  # TrackPoint).  Each instance of this class has its own meta-data, including
  # low point, high point, and distance.  Of course, each track references an
  # array of the segments that copmrise it, but additionally each track holds
  # a reference to all of its points as one big array called "points".
  class Track < Base
    attr_reader :points, :bounds, :lowest_point, :highest_point, :distance
    attr_accessor :segments, :name, :gpx_file

    # Initialize a track from a XML::Node, or, if no :element option is
    # passed, initialize a blank Track object.
    def initialize(opts = {})
      @gpx_file = opts[:gpx_file]
      @segments = []
      @points = []
      reset_meta_data
      if(opts[:element])
        trk_element = opts[:element]
        @name = (trk_element.at("name").inner_text rescue "")
        trk_element.search("trkseg").each do |seg_element|
          seg = Segment.new(:element => seg_element, :track => self, :gpx_file => @gpx_file)
          update_meta_data(seg)
          @segments << seg
        end
      end
    end

    # Append a segment to this track, updating its meta data along the way.
    def append_segment(seg)
      update_meta_data(seg)
      @segments << seg
      @points.concat(seg.points) unless seg.nil?
    end

    # Returns true if the given time occurs within any of the segments of this track.
    def contains_time?(time)
      segments.each do |seg|
        return true if seg.contains_time?(time)
      end
      return false
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
      segments.delete_if { |seg| seg.empty? }
    end

    # Deletes all points within a given area and updates the meta data.
    def delete_area(area)
      reset_meta_data
      segments.each do |seg|
        seg.delete_area(area)
        update_meta_data(seg) unless seg.empty?
      end
      segments.delete_if { |seg| seg.empty? }
    end

    # Returns true if this track has no points in it.  This should return
    # true even when the track has empty segments.
    def empty?
      (points.nil? or points.size.zero?)
    end

    # Prints out a friendly summary of this track (sans points).  Useful for
    # debugging and sanity checks.

    def to_s
      result = "Track \n"
      result << "\tName: #{name}\n"
      result << "\tSize: #{points.size} points\n"
      result << "\tSegments: #{segments.size} \n"
      result << "\tDistance: #{distance} km\n"
      result << "\tLowest Point: #{lowest_point.elevation} \n"
      result << "\tHighest Point: #{highest_point.elevation}\n "
      result << "\tBounds: #{bounds.to_s}"
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
      @lowest_point   = seg.lowest_point if(@lowest_point.nil? or seg.lowest_point.elevation < @lowest_point.elevation)
      @highest_point  = seg.highest_point if(@highest_point.nil? or seg.highest_point.elevation > @highest_point.elevation)
      @bounds.add(seg.bounds)
      @distance += seg.distance
      @points.concat(seg.points)
    end

    def reset_meta_data
      @bounds = Bounds.new
      @highest_point = nil
      @lowest_point = nil
      @distance = 0.0
      @points = []
    end

  end
end
