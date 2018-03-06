require 'minitest/autorun'
require 'gpx'

class GPXFileTest < Minitest::Test
  ONE_TRACK_FILE = File.join(File.dirname(__FILE__), 'gpx_files/one_track.gpx')
  WITH_OR_WITHOUT_ELEV_FILE = File.join(File.dirname(__FILE__), 'gpx_files/with_or_without_elev.gpx')
  WITH_EMPTY_TRACKS = File.join(File.dirname(__FILE__), 'gpx_files/with_empty_tracks.gpx')
  BIG_FILE = File.join(File.dirname(__FILE__), 'gpx_files/big.gpx')

  def test_load_data_from_string
    gpx_file = GPX::GPXFile.new(gpx_data: File.open(ONE_TRACK_FILE).read)
    assert_equal(1, gpx_file.tracks.size)
    assert_equal(8, gpx_file.tracks.first.segments.size)
    assert_equal('ACTIVE LOG', gpx_file.tracks.first.name)
    assert_equal('active_log.gpx', gpx_file.name)
    assert_equal('2006-04-08T16:44:28Z', gpx_file.time.xmlschema)
    assert_equal(38.681488, gpx_file.bounds.min_lat)
    assert_equal(-109.606948, gpx_file.bounds.min_lon)
    assert_equal(38.791759, gpx_file.bounds.max_lat)
    assert_equal(-109.447045, gpx_file.bounds.max_lon)
    assert_equal('description of my GPX file with special char like &, <, >', gpx_file.description)
    assert_equal('description of my GPX file with special char like &, <, >', gpx_file.description)
    assert_equal(3.0724966849262554, gpx_file.distance)
    assert_equal(15_237.0, gpx_file.duration)
    assert_equal(3036.0, gpx_file.moving_duration)
    assert_equal(3.6432767014935834, gpx_file.average_speed)
  end

  def test_load_data_from_file
    gpx_file = GPX::GPXFile.new(gpx_file: ONE_TRACK_FILE)
    assert_equal(1, gpx_file.tracks.size)
    assert_equal(8, gpx_file.tracks.first.segments.size)
    assert_equal('ACTIVE LOG', gpx_file.tracks.first.name)
    assert_equal('active_log.gpx', gpx_file.name)
    assert_equal('2006-04-08T16:44:28Z', gpx_file.time.xmlschema)
    assert_equal(38.681488, gpx_file.bounds.min_lat)
    assert_equal(-109.606948, gpx_file.bounds.min_lon)
    assert_equal(38.791759, gpx_file.bounds.max_lat)
    assert_equal(-109.447045, gpx_file.bounds.max_lon)
    assert_equal('description of my GPX file with special char like &, <, >', gpx_file.description)
    assert_equal(3.0724966849262554, gpx_file.distance)
    assert_equal(15_237.0, gpx_file.duration)
    assert_equal(3036.0, gpx_file.moving_duration)
    assert_equal(3.6432767014935834, gpx_file.average_speed)
  end

  def test_big_file
    gpx_file = GPX::GPXFile.new(gpx_file: BIG_FILE)
    assert_equal(1, gpx_file.tracks.size)
    assert_equal(7968, gpx_file.tracks.first.points.size)
    assert_equal(105_508.0, gpx_file.duration)
    assert_equal(57_645.0, gpx_file.moving_duration)
    assert_in_delta(99.60738958686505, gpx_file.average_speed, 1e-13)
  end

  def test_with_or_with_elev
    gpx_file = GPX::GPXFile.new(gpx_file: WITH_OR_WITHOUT_ELEV_FILE)
    assert_equal(2, gpx_file.tracks.size)
    assert_equal(0, gpx_file.duration)
    assert_equal(0, gpx_file.moving_duration)
    assert(gpx_file.average_speed.nan?)
    # assert_equal(7968, gpx_file.tracks.first.points.size)
  end

  def test_with_empty_tracks
    gpx_file = GPX::GPXFile.new(gpx_file: WITH_EMPTY_TRACKS)
    # is read correctly
    assert_equal(1, gpx_file.tracks.size)
    # and ignores empty segments
    assert_equal(1, gpx_file.tracks.first.segments.size)
    assert_equal(21.0, gpx_file.duration)
    assert_equal(21.0, gpx_file.moving_duration)
    assert_equal(6.674040636626879, gpx_file.average_speed)
  end
end
