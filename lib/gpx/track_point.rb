module GPX
  # Basically the same as a point, the TrackPoint class is supposed to
  # represent the points that are children of Segment elements.  So, the only
  # real difference is that TrackPoints hold a reference to their parent
  # Segments.
  class TrackPoint < Point
    RADIUS = 6371 # earth's mean radius in km

    attr_accessor :segment

    def initialize(opts = {})
      super(opts)
      @segment = opts[:segment]
    end

    # Units are in km
    def haversine_distance_from(p2)
      d_lat = p2.latr - latr
      d_lon = p2.lonr - lonr
      a = Math.sin(d_lat / 2) * Math.sin(d_lat / 2) + Math.cos(latr) * Math.cos(p2.latr) * Math.sin(d_lon / 2) * Math.sin(d_lon / 2)
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
      RADIUS * c
    end

    # Units are in km
    def law_of_cosines_distance_from(p2)
      Math.acos(Math.sin(latr) * Math.sin(p2.latr) + Math.cos(latr) * Math.cos(p2.latr) * Math.cos(p2.lonr - lonr)) * RADIUS
    end
  end
end
