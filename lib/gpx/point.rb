# frozen_string_literal: true

module GPX
  # The base class for all points.  Trackpoint and Waypoint both descend from this base class.
  class Point < Base
    D_TO_R = Math::PI / 180.0
    attr_accessor :time, :elevation, :gpx_file, :speed, :extensions
    attr_reader :lat, :lon

    # When you need to manipulate individual points, you can create a Point
    # object with a latitude, a longitude, an elevation, and a time.  In
    # addition, you can pass an XML element to this initializer, and the
    # relevant info will be parsed out.
    def initialize(opts = { lat: 0.0, lon: 0.0, elevation: 0.0, time: Time.now })
      @gpx_file = opts[:gpx_file]
      if opts[:element]
        elem = opts[:element]
        @lat = elem['lat'].to_f
        @lon = elem['lon'].to_f
        @latr = (D_TO_R * @lat)
        @lonr = (D_TO_R * @lon)
        # '-'? yyyy '-' mm '-' dd 'T' hh ':' mm ':' ss ('.' s+)? (zzzzzz)?
        @time = (
        begin
          Time.xmlschema(elem.at('time').inner_text)
        rescue StandardError
          nil
        end)
        @elevation = elem.at('ele').inner_text.to_f unless elem.at('ele').nil?
        @speed = elem.at('speed').inner_text.to_f unless elem.at('speed').nil?
        @extensions = elem.at('extensions') unless elem.at('extensions').nil?
      else
        @lat = opts[:lat]
        @lon = opts[:lon]
        @elevation = opts[:elevation]
        @time = opts[:time]
        @speed = opts[:speed]
        @extensions = opts[:extensions]
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
  end
end
