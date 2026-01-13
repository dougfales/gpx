# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'
require 'gpx'

class OutputTest < Minitest::Test
  include GPX

  def setup
    FileUtils.mkdir_p(File.join(File.dirname(__FILE__), 'output'))
  end

  def test_new_gpx_file_from_scratch
    gpx_file = GPXFile.new

    track = Track.new(name: 'My First Track')
    segment = Segment.new

    track_point_data = [
      { lat: 40.036926, lon: -105.253487, time: Time.parse('2005-12-31T22:01:24Z'), elevation: 1737.24 },
      { lat: 40.036604, lon: -105.253487, time: Time.parse('2005-12-31T22:02:01Z'), elevation: 1738.682 },
      { lat: 40.036347, lon: -105.253830, time: Time.parse('2005-12-31T22:02:08Z'), elevation: 1738.682 },
      { lat: 40.035574, lon: -105.254045, time: Time.parse('2005-12-31T22:02:20Z'), elevation: 1737.24 },
      { lat: 40.035467, lon: -105.254366, time: Time.parse('2005-12-31T22:02:29Z'), elevation: 1735.798 },
      { lat: 40.035317, lon: -105.254388, time: Time.parse('2005-12-31T22:02:33Z'), elevation: 1735.798 },
      { lat: 40.035274, lon: -105.254431, time: Time.parse('2005-12-31T22:02:49Z'), elevation: 1736.278 },
      { lat: 40.035274, lon: -105.254431, time: Time.parse('2005-12-31T22:02:54Z'), elevation: 1739.643 },
      { lat: 40.035317, lon: -105.254431, time: Time.parse('2005-12-31T22:05:08Z'), elevation: 1732.433 },
      { lat: 40.035317, lon: -105.254431, time: Time.parse('2005-12-31T22:05:09Z'), elevation: 1726.665 }
    ]

    track_point_data.each do |trk_pt_hash|
      segment.points << TrackPoint.new(trk_pt_hash)
    end

    track.segments << segment
    gpx_file.tracks << track

    waypoint_data = [
      { lat: 39.997298, lon: -105.292674, name: 'GRG-CA', sym: 'Waypoint', ele: '1766.535' },
      { lat: 33.330190, lon: -111.946110, name: 'GRMPHX', sym: 'Waypoint', ele: '361.0981',
        cmt: "Hey here's a comment.", desc: 'Somewhere in my backyard.', fix: '3d', sat: '8', hdop: '50.5', vdop: '6.8', pdop: '7.6' },
      { lat: 25.061783, lon: 121.640267,  name: 'GRMTWN', sym: 'Waypoint', ele: '38.09766' },
      { lat: 39.999840, lon: -105.214696, name: 'SBDR',   sym: 'Waypoint', ele: '1612.965' },
      { lat: 39.989739, lon: -105.295285, name: 'TO',     sym: 'Waypoint', ele: '2163.556' },
      { lat: 40.035301, lon: -105.254443, name: 'VICS',   sym: 'Waypoint', ele: '1535.34' },
      { lat: 40.035301, lon: -105.254443, name: 'TIMEDWPT', sym: 'Waypoint', ele: '1535.34', time: Time.parse('2005-12-31T22:05:09Z') }
    ]

    waypoint_data.each do |wpt_hash|
      gpx_file.waypoints << Waypoint.new(wpt_hash)
    end

    route_point_data = [
      { lat: 40.035467, lon: -105.254366, time: Time.parse('2005-12-31T22:02:29Z'), elevation: 1735.798 },
      { lat: 40.035317, lon: -105.254388, time: Time.parse('2005-12-31T22:02:33Z'), elevation: 1735.798 },
      { lat: 40.035274, lon: -105.254431, time: Time.parse('2005-12-31T22:02:49Z'), elevation: 1736.278 }
    ]

    route = Route.new
    route_point_data.each do |rte_pt_hash|
      route.points << Point.new(rte_pt_hash)
    end

    gpx_file.routes << route

    gpx_file.write(output_file(name_of_test))

    written_gpx_file = GPXFile.new(gpx_file: output_file(name_of_test))

    assert_equal(File.basename(output_file(name_of_test)), written_gpx_file.name)
    assert_equal(1, written_gpx_file.tracks.size)
    assert_equal(1, written_gpx_file.tracks[0].segments.size)
    assert_equal(track_point_data.size, written_gpx_file.tracks[0].segments[0].points.size)
    assert_equal(track_point_data.size, written_gpx_file.tracks[0].points.size)

    # Make sure each point in the segment has the attributes it was initialized with
    written_segment = written_gpx_file.tracks[0].segments[0]
    track_point_data.each_with_index do |trk_pt_hash, index|
      trk_pt_hash.each do |key, value|
        assert_equal(value, written_segment.points[index].send(key))
      end
    end

    # Make sure the one route has the attributes we initialized it with
    assert_equal(1, written_gpx_file.routes.size)
    written_route = written_gpx_file.routes[0]
    assert_equal(route_point_data.size, written_route.points.size)
    route_point_data.each_with_index do |rte_pt_hash, index|
      rte_pt_hash.each do |key, value|
        assert_equal(value, written_route.points[index].send(key))
      end
    end

    # Make sure the waypoints have all of the attributes we initialized them with
    written_waypoints = written_gpx_file.waypoints
    assert_equal(waypoint_data.size, written_waypoints.size)
    waypoint_data.each_with_index do |wpt_hash, index|
      wpt_hash.each do |key, value|
        assert_equal(value, written_waypoints[index].send(key.to_s), key)
      end
    end
  end

  def name_of_test
    caller[0] =~ /`test_([^']*)'/ && Regexp.last_match(1)
  end

  def output_file(test_name)
    File.join(File.dirname(__FILE__), "output/#{test_name}.gpx")
  end
end
