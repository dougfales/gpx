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
      # addition, you can pass a REXML element to this initializer, and the
      # relevant info will be parsed out.
      def initialize(opts = {:lat => 0.0, :lon => 0.0, :elevation => 0.0, :time => Time.now } )
         if (opts[:element]) 
            elem = opts[:element]
            @lat, @lon = elem.attributes["lat"].to_f, elem.attributes["lon"].to_f
            @latr, @lonr = (D_TO_R * @lat), (D_TO_R * @lon)
            #'-'? yyyy '-' mm '-' dd 'T' hh ':' mm ':' ss ('.' s+)? (zzzzzz)?
            @time = (Time.xmlschema(elem.elements["time"].text) rescue nil)
            @elevation = elem.elements["ele"].text.to_f if elem.elements["ele"]
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

      # Convert this point to a REXML::Element.
      def to_xml(elem_name = 'trkpt')
         pt = Element.new('trkpt')
         pt.attributes['lat'] = lat
         pt.attributes['lon'] = lon
         unless time.nil?
            time_elem = Element.new('time')
            time_elem.text = time.xmlschema
            pt.elements << time_elem
         end
         elev = Element.new('ele')
         elev.text = elevation
         pt.elements << elev
         pt
      end

   end
end
