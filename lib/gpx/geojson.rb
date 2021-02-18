# frozen_string_literal: true

require 'json'

module GPX
  # Class to parse GeoJSON LineStrings, MultiLineStrings, Points,
  # and MultiPoint geometric objects to GPX format. For the full
  # specification of GeoJSON, see:
  #   http://geojson.org/geojson-spec.html
  # Note that GeoJSON coordinates are specified in lon/lat format,
  # instead of the more traditional lat/lon format.
  #
  class Geojson
    class << self
      FEATURE = 'Feature'
      LINESTRING = 'LineString'
      MULTILINESTRING = 'MultiLineString'
      POINT = 'Point'
      MULTIPOINT = 'MultiPoint'

      # Conversion can be initiated by either specifying a file,
      # file name, or by passing in GeoJSON data as a string.
      # Examples:
      #   GPX::Geojson.convert_to_gpx(geojson_file: 'mygeojsonfile.json')
      # or
      #   file = File.new('mygeojsonfile.json', 'r')
      #   GPX::Geojson.convert_to_gpx(geojson_file: file)
      # or
      #   data = JSON.generate(my_geojson_hash)
      #   GPX::Geojson.convert_to_gpx(geojson_data: data)
      #
      # Returns a GPX::GPX_File object populated with the converted data.
      #
      def convert_to_gpx(opts = {})
        geojson = geojson_data_from(opts)
        gpx_file = GPX::GPXFile.new
        add_tracks_to(gpx_file, geojson)
        add_waypoints_to(gpx_file, geojson)
        gpx_file
      end

      private

      def geojson_data_from(opts)
        if opts[:geojson_file]
          parse_geojson_data_from_file(opts[:geojson_file])
        elsif opts[:geojson_data]
          parse_geojson_data(opts[:geojson_data])
        else
          raise ArgumentError,
                'Must pass value for \':geojson_file\' ' \
                'or \':geojson_data\' to convert_to_gpx'
        end
      end

      def parse_geojson_data_from_file(filename)
        parse_geojson_data(IO.read(filename))
      end

      def parse_geojson_data(data)
        JSON.parse(data)
      end

      def add_tracks_to(gpx_file, geojson)
        tracks = [line_strings_to_track(geojson)] +
                 multi_line_strings_to_tracks(geojson)
        tracks.reject!(&:nil?)
        gpx_file.tracks += tracks
        gpx_file.tracks.each { |t| gpx_file.update_meta_data(t) }
      end

      def add_waypoints_to(gpx_file, geojson)
        gpx_file.waypoints +=
          points_to_waypoints(geojson, gpx_file) +
          multi_points_to_waypoints(geojson, gpx_file)
      end

      # Converts GeoJSON 'LineString' features.
      # Current strategy is to convert each LineString into a
      # Track Segment, returning a Track for all LineStrings.
      #
      def line_strings_to_track(geojson)
        line_strings = line_strings_in(geojson)
        return nil unless line_strings.any?

        track = GPX::Track.new
        line_strings.each do |ls|
          coords = ls['geometry']['coordinates']
          track.append_segment(coords_to_segment(coords))
        end
        track
      end

      # Converts GeoJSON 'MultiLineString' features.
      # Current strategy is to convert each MultiLineString
      # into a Track, with each set of LineString coordinates
      # within a MultiLineString a Track Segment.
      #
      def multi_line_strings_to_tracks(geojson)
        tracks = []
        multi_line_strings_in(geojson).each do |mls|
          track = GPX::Track.new
          mls['geometry']['coordinates'].each do |coords|
            seg = coords_to_segment(coords)
            seg.track = track
            track.append_segment(seg)
          end
          tracks << track
        end
        tracks
      end

      # Converts GeoJSON 'Point' features.
      # Current strategy is to convert each Point
      # feature into a GPX waypoint.
      #
      def points_to_waypoints(geojson, gpx_file)
        waypoints = []
        points_in(geojson).each do |pt|
          coords = pt['geometry']['coordinates']
          waypoints << point_to_waypoint(coords, gpx_file)
        end
        waypoints
      end

      # Converts GeoJSON 'MultiPoint' features.
      # Current strategy is to convert each coordinate
      # point in a MultiPoint to a GPX waypoint.
      #
      # NOTE: It is debatable that a MultiPoint feature
      # might translate best into a GPX route, which is
      # described as
      #   "an ordered list of waypoints representing a
      #    series of turn points leading to a destination."
      # See http://www.topografix.com/gpx/1/1/#type_rteType
      #
      def multi_points_to_waypoints(geojson, gpx_file)
        waypoints = []
        multi_points_in(geojson).each do |mpt|
          mpt['geometry']['coordinates'].each do |coords|
            waypoints << point_to_waypoint(coords, gpx_file)
          end
        end
        waypoints
      end

      # Given an array of [lng, lat, ele] coordinates,
      # return a GPX track segment.
      #
      def coords_to_segment(coords)
        seg = GPX::Segment.new
        coords.each do |pt|
          seg.append_point(point_to_track_point(pt, seg))
        end
        seg
      end

      # Given a GeoJSON coordinate point, return
      # a GPX::Waypoint
      def point_to_waypoint(point, gpx_file)
        GPX::Waypoint.new(gpx_file: gpx_file,
                          lon: point[0],
                          lat: point[1],
                          elevation: point[2])
      end

      # Given a GeoJSON coorindate point, and
      # GPX segment, return a GPX::TrackPoint.
      #
      def point_to_track_point(point, seg)
        GPX::TrackPoint.new(segment: seg,
                            lon: point[0],
                            lat: point[1],
                            elevation: point[2])
      end

      # Returns all features in the passed geojson
      # that match the type.
      #
      def features_for(geojson, type)
        geojson['features'].find_all do |f|
          f['type'] == FEATURE && f['geometry']['type'] == type
        end
      end

      def points_in(geojson)
        features_for(geojson, POINT)
      end

      def multi_points_in(geojson)
        features_for(geojson, MULTIPOINT)
      end

      def line_strings_in(geojson)
        features_for(geojson, LINESTRING)
      end

      def multi_line_strings_in(geojson)
        features_for(geojson, MULTILINESTRING)
      end
    end
  end
end
