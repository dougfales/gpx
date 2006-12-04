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
include Math
module GPX
   # The base class for all points.  Trackpoint and Waypoint both descend from this base class.
   class Point < Base
      D_TO_R = PI/180.0;
      attr_accessor :lat, :lon, :time, :elevation

      # When you need to manipulate individual points, you can create a Point
      # object with a latitude, a longitude, an elevation, and a time.  In
      # addition, you can pass an XML element to this initializer, and the
      # relevant info will be parsed out.
      def initialize(opts = {:lat => 0.0, :lon => 0.0, :elevation => 0.0, :time => Time.now } )
         if (opts[:element]) 
            elem = opts[:element]
            @lat, @lon = elem["lat"].to_f, elem["lon"].to_f
            @latr, @lonr = (D_TO_R * @lat), (D_TO_R * @lon)
            #'-'? yyyy '-' mm '-' dd 'T' hh ':' mm ':' ss ('.' s+)? (zzzzzz)?
            @time = (Time.xmlschema(elem.find("gpx:time", NS).first.content) rescue nil)
            @elevation = elem.find("gpx:ele", NS).first.content.to_f unless elem.find("gpx:ele", NS).empty?
         else
            @lat = opts[:lat]
            @lon = opts[:lon]
            @elevation = opts[:elevation]
            @time = opts[:time]
         end

      end


      # Returns the latitude and longitude (in that order), separated by the
      # given delimeter.  This is useful for passing a point into another API
      # (i.e. the Google Maps javascript API).
      def lat_lon(delim = ', ')
        "#{lat}#{delim}#{lon}"
      end

      # Returns the longitude and latitude (in that order), separated by the
      # given delimeter.  This is useful for passing a point into another API
      # (i.e. the Google Maps javascript API).
      def lon_lat(delim = ', ')
        "#{lon}#{delim}#{lat}"
      end

      # Latitude in radians.
      def latr
         @latr ||= (@lat * D_TO_R)
      end

      # Longitude in radians.
      def lonr
         @lonr ||= (@lon * D_TO_R)
      end

      # Set the latitude (in degrees).
      def lat=(latitude)
         @latr = (latitude * D_TO_R)
         @lat = latitude
      end

      # Set the longitude (in degrees).
      def lon=(longitude)
         @lonr = (longitude * D_TO_R)
         @lon = longitude
      end

      # Convert this point to a XML::Node.
      def to_xml(elem_name = 'trkpt')
         pt = Node.new('trkpt')
         pt['lat'] = lat.to_s
         pt['lon'] = lon.to_s
         unless time.nil?
            time_elem = Node.new('time')
            time_elem << time.xmlschema
            pt << time_elem
         end
         elev = Node.new('ele')
         elev << elevation
         pt <<  elev
         pt
      end

   end
end
