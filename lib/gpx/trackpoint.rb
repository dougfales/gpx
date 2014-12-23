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
  # Basically the same as a point, the TrackPoint class is supposed to
  # represent the points that are children of Segment elements.  So, the only
  # real difference is that TrackPoints hold a reference to their parent
  # Segments.
  class TrackPoint < Point
    RADIUS = 6371; # earth's mean radius in km

    attr_accessor :segment


    def initialize(opts = {})
      super(opts)
      @segment = opts[:segment]
    end

    # Units are in km
    def haversine_distance_from(p2)
      d_lat = p2.latr - latr;
      d_lon = p2.lonr - lonr;
      a = Math.sin(d_lat/2) * Math.sin(d_lat/2) + Math.cos(latr) * Math.cos(p2.latr) * Math.sin(d_lon/2) * Math.sin(d_lon/2);
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
      d = RADIUS * c;
      return d;
    end

    # Units are in km
    def pythagorean_distance_from(p2)
      Math.sqrt((p2.latr - latr)**2 + (p2.lonr - lonr)**2)
    end

    # Units are in km
    def law_of_cosines_distance_from(p2)
      (Math.acos(Math.sin(latr)*Math.sin(p2.latr) + Math.cos(latr)*Math.cos(p2.latr)*Math.cos(p2.lonr-lonr)) * RADIUS)
    end

  end
end
