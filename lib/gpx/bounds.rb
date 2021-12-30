# frozen_string_literal: true

module GPX
  class Bounds < Base
    attr_accessor :min_lat, :max_lat, :max_lon, :min_lon

    # Creates a new bounds object with the passed-in min and max longitudes
    # and latitudes.
    def initialize(opts = { min_lat: 90.0, max_lat: -90.0, min_lon: 180.0, max_lon: -180.0 })
      super()
      @min_lat = opts[:min_lat].to_f
      @max_lat = opts[:max_lat].to_f
      @min_lon = opts[:min_lon].to_f
      @max_lon = opts[:max_lon].to_f
    end

    # Returns the middle latitude.
    def center_lat
      distance = (max_lat - min_lat) / 2.0
      (min_lat + distance)
    end

    # Returns the middle longitude.
    def center_lon
      distance = (max_lon - min_lon) / 2.0
      (min_lon + distance)
    end

    # Returns true if the pt is within these bounds.
    def contains?(pt)
      ((pt.lat >= min_lat) && (pt.lat <= max_lat) && (pt.lon >= min_lon) && (pt.lon <= max_lon))
    end

    # Adds an item to itself, expanding its min/max lat/lon as needed to
    # contain the given item.  The item can be either another instance of
    # Bounds or a Point.
    def add(item)
      if item.respond_to?(:lat) && item.respond_to?(:lon)
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
