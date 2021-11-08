# frozen_string_literal: true

require 'minitest/autorun'
require 'gpx'
require 'json'

class GeojsonTest < Minitest::Test
  # Test passing a file name
  def test_geojson_file_name_as_param
    file_name = "#{File.dirname(__FILE__)}/geojson_files/line_string_data.json"
    gpx_file = GPX::GeoJSON.convert_to_gpx(geojson_file: file_name)
    assert_equal(1, gpx_file.tracks.size)
  end

  # Test passing a file
  def test_geojson_file_as_param
    file_name = "#{File.dirname(__FILE__)}/geojson_files/line_string_data.json"
    file = File.new(file_name, 'r')
    gpx_file = GPX::GeoJSON.convert_to_gpx(geojson_file: file)
    assert_equal(1, gpx_file.tracks.size)
  end

  def test_raises_arg_error_when_no_params
    assert_raises(ArgumentError) do
      GPX::GeoJSON.convert_to_gpx
    end
  end

  # Test that lat/lon allocated correctly
  def test_point_to_waypoint
    pt = [-118, 34]
    waypoint = GPX::GeoJSON.send(:point_to_waypoint, pt, nil)
    assert_equal(34, waypoint.lat)
    assert_equal(-118, waypoint.lon)
  end

  # Test that lat/lon allocated correctly
  def test_point_to_trackpoint
    pt = [-118, 34]
    waypoint = GPX::GeoJSON.send(:point_to_track_point, pt, nil)
    assert_equal(34, waypoint.lat)
    assert_equal(-118, waypoint.lon)
  end

  def test_line_string_functionality
    file = File.join(File.dirname(__FILE__), 'geojson_files/line_string_data.json')
    gpx_file = GPX::GeoJSON.convert_to_gpx(geojson_file: file)

    assert_equal(1, gpx_file.tracks.size)
    assert_equal(3, gpx_file.tracks.first.segments.size)
    pts_size = gpx_file.tracks.first.segments[0].points.size +
               gpx_file.tracks.first.segments[1].points.size +
               gpx_file.tracks.first.segments[2].points.size
    assert_equal(58, pts_size)
  end

  def test_multi_line_string_functionality
    file = File.join(File.dirname(__FILE__), 'geojson_files/multi_line_string_data.json')
    gpx_file = GPX::GeoJSON.convert_to_gpx(geojson_file: file)
    assert_equal(1, gpx_file.tracks.size)
    assert_equal(3, gpx_file.tracks.first.segments.size)
    pts_size = gpx_file.tracks.first.segments[0].points.size +
               gpx_file.tracks.first.segments[1].points.size +
               gpx_file.tracks.first.segments[2].points.size
    assert_equal(58, pts_size)
  end

  def test_point_functionality
    file = File.join(File.dirname(__FILE__), 'geojson_files/point_data.json')
    gpx_file = GPX::GeoJSON.convert_to_gpx(geojson_file: file)
    assert_equal(3, gpx_file.waypoints.size)
  end

  def test_multi_point_functionality
    file = File.join(File.dirname(__FILE__), 'geojson_files/multi_point_data.json')
    gpx_file = GPX::GeoJSON.convert_to_gpx(geojson_file: file)
    assert_equal(3, gpx_file.waypoints.size)
  end

  def test_combined_functionality
    file = File.join(File.dirname(__FILE__), 'geojson_files/combined_data.json')
    gpx_file = GPX::GeoJSON.convert_to_gpx(geojson_file: file)

    # 1 for all LineStrings, 1 for MultiLineString
    assert_equal(2, gpx_file.tracks.size)
    assert_equal(3, gpx_file.tracks.first.segments.size)
    assert_equal(2, gpx_file.tracks.last.segments.size)
    pt_sum = gpx_file.tracks.inject(0) { |sum, trk| sum + trk.points.size }
    assert_equal(16, pt_sum)
    assert_equal(4, gpx_file.waypoints.size)
  end
end
