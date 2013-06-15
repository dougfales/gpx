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
   class Bounds < Base
      attr_accessor :min_lat, :max_lat, :max_lon, :min_lon, :center_lat, :center_lon

      # Creates a new bounds object with the passed-in min and max longitudes
      # and latitudes.
      def initialize(opts = { :min_lat => 90.0, :max_lat => -90.0, :min_lon => 180.0, :max_lon => -180.0})
         @min_lat, @max_lat  = opts[:min_lat].to_f, opts[:max_lat].to_f
         @min_lon, @max_lon  = opts[:min_lon].to_f, opts[:max_lon].to_f
      end

      # Returns the middle latitude.
      def center_lat
         distance = (max_lat - min_lat)/2.0
         (min_lat + distance)
      end

      # Returns the middle longitude.
      def center_lon
         distance = (max_lon - min_lon)/2.0
         (min_lon + distance)
      end

      # Returns true if the pt is within these bounds.
      def contains?(pt)
         (pt.lat >=  min_lat and pt.lat <= max_lat and pt.lon >= min_lon and pt.lon <= max_lon)
      end

      # Adds an item to itself, expanding its min/max lat/lon as needed to
      # contain the given item.  The item can be either another instance of
      # Bounds or a Point.
      def add(item)
         if(item.respond_to?(:lat) and item.respond_to?(:lon))
            @min_lat = item.lat if item.lat < @min_lat
            @min_lon = item.lon if item.lon < @min_lon
            @max_lat = item.lat if item.lat > @max_lat
            @max_lon = item.lon if item.lon > @max_lon
         else
            @min_lat = item.min_lat if item.min_lat < @min_lat
            @min_lon = item.min_lon if item.min_lon < @min_lon
            @max_lat = item.max_lat if item.max_lat > @max_lat
            @max_lon = item.max_lon if item.max_lon > @max_lon
         end
      end

      # Returns the min_lat, min_lon, max_lat, and max_lon in a labeled string.
      def to_s
         "min_lat: #{min_lat} min_lon: #{min_lon} max_lat: #{max_lat} max_lon: #{max_lon}"
      end

   end
end
