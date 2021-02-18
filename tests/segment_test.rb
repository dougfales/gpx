# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'
require 'gpx'

class SegmentTest < Minitest::Test
  ONE_SEGMENT = File.join(File.dirname(__FILE__), 'gpx_files/one_segment.gpx')
  ONE_SEGMENT_NO_TIME = File.join(File.dirname(__FILE__), 'gpx_files/one_segment_no_time.gpx')

  def setup
    @gpx_file = GPX::GPXFile.new(gpx_file: ONE_SEGMENT)
    @segment = @gpx_file.tracks.first.segments.first
  end

  def test_segment_read
    assert_equal(189, @segment.points.size)
    assert_equal(1_144_433_525, @segment.earliest_point.time.to_i)
    assert_equal(1_144_437_991, @segment.latest_point.time.to_i)
    assert_equal(1334.447, @segment.lowest_point.elevation)
    assert_equal(1480.087, @segment.highest_point.elevation)
    assert_in_delta(6.98803359528853, @segment.distance, 0.001)
    assert_equal(4466.0, @segment.duration)
  end

  def test_segment_read_no_time
    gpx_file_no_time = GPX::GPXFile.new(gpx_file: ONE_SEGMENT_NO_TIME)
    segment_no_time = gpx_file_no_time.tracks.first.segments.first
    assert_equal(189, segment_no_time.points.size)
    assert_equal(1334.447, segment_no_time.earliest_point.elevation)
    assert_equal(1413.756, segment_no_time.latest_point.elevation)
    assert_equal(1334.447, segment_no_time.lowest_point.elevation)
    assert_equal(1480.087, segment_no_time.highest_point.elevation)
    assert_in_delta(6.98803359528853, segment_no_time.distance, 0.001)
    assert_equal(0, segment_no_time.duration)
  end

  def test_segment_crop
    crop_rectangle = GPX::Bounds.new(min_lat: 39.173000,
                                     min_lon: -109.010000,
                                     max_lat: 39.188000,
                                     max_lon: -108.999000)
    @segment.crop(crop_rectangle)

    assert_equal(106, @segment.points.size)
    assert_in_delta(4.11422061733046, @segment.distance, 0.001)
    assert_equal(1_144_435_041, @segment.earliest_point.time.to_i)
    assert_equal(1_144_437_752, @segment.latest_point.time.to_i)
    assert_equal(1407.027, @segment.lowest_point.elevation)
    assert_equal(1480.087, @segment.highest_point.elevation)
    assert_equal(39.173834, @segment.bounds.min_lat)
    assert_equal(-109.009995, @segment.bounds.min_lon)
    assert_equal(39.187868,   @segment.bounds.max_lat)
    assert_equal(-108.999546, @segment.bounds.max_lon)
    assert_equal(2711.0, @segment.duration)
  end

  def test_segment_delete
    delete_rectangle = GPX::Bounds.new(min_lat: 39.173000,
                                       min_lon: -109.010000,
                                       max_lat: 39.188000,
                                       max_lon: -108.999000)
    @segment.delete_area(delete_rectangle)
    assert_equal(83, @segment.points.size)
    assert_in_delta(3.35967118153605, @segment.distance, 0.001)
    assert_equal(1_144_433_525, @segment.earliest_point.time.to_i)
    assert_equal(1_144_437_991, @segment.latest_point.time.to_i)
    assert_equal(1334.447, @segment.lowest_point.elevation)
    assert_equal(1428.176, @segment.highest_point.elevation)
    assert_equal(39.180572, @segment.bounds.min_lat)
    assert_equal(-109.016604, @segment.bounds.min_lon)
    assert_equal(39.188747,   @segment.bounds.max_lat)
    assert_equal(-109.007978, @segment.bounds.max_lon)
    assert_equal(4466.0, @segment.duration)
  end

  def test_segment_smooth
    @segment.smooth_location_by_average
    assert_equal(189, @segment.points.size)
    assert_equal(1_144_433_525, @segment.earliest_point.time.to_i)
    assert_equal(1_144_437_991, @segment.latest_point.time.to_i)
    assert_equal(1342.58, @segment.lowest_point.elevation)
    assert_equal(1479.09, @segment.highest_point.elevation)
    assert_in_delta(6.458085658, @segment.distance, 0.001)
    assert_equal(4466.0, @segment.duration)
  end

  def test_segment_smooth_offset
    @segment.smooth_location_by_average(start: 1000, end: 2000)
    assert_equal(189, @segment.points.size)
    assert_equal(1_144_433_525, @segment.earliest_point.time.to_i)
    assert_equal(1_144_437_991, @segment.latest_point.time.to_i)
    assert_equal(1334.447, @segment.lowest_point.elevation)
    assert_equal(1480.087, @segment.highest_point.elevation)
    assert_in_delta(6.900813095, @segment.distance, 0.001)
    assert_equal(4466.0, @segment.duration)
  end

  def test_segment_smooth_absolute
    @segment.smooth_location_by_average(start: Time.at(1_144_434_520), end: Time.at(1_144_435_520))
    assert_equal(189, @segment.points.size)
    assert_equal(1_144_433_525, @segment.earliest_point.time.to_i)
    assert_equal(1_144_437_991, @segment.latest_point.time.to_i)
    assert_equal(1334.447, @segment.lowest_point.elevation)
    assert_equal(1480.087, @segment.highest_point.elevation)
    assert_in_delta(6.900813095, @segment.distance, 0.001)
    assert_equal(4466.0, @segment.duration)
  end
end
