require 'minitest/autorun'
require 'gpx'

class TrackPointTest < Minitest::Test
  def setup
    @point1 = GPX::TrackPoint.new(
      lat: 37.7985474,
      lon: -122.2554386
    )
    @point2 = GPX::TrackPoint.new(
      lat: 37.7985583,
      lon: -122.2554564
    )
    @point3 = GPX::TrackPoint.new(
      lat: 38.7985583,
      lon: -121.2554564
    )
  end

  def test_haversine_distance_from
    distance = @point1.haversine_distance_from(@point2)
    assert_in_delta(0.00197862991592239, distance, 1e-18)
  end

  def test_longer_haversine_distance_from
    distance = @point2.haversine_distance_from(@point3)
    assert_in_delta(141.3465338444813, distance, 1e-18)
  end

  def test_law_of_cosines_distance_from
    distance = @point1.law_of_cosines_distance_from(@point2)
    assert_equal(0.001982307218559664, distance)
  end

  def test_longer_law_of_cosines_distance_from
    distance = @point2.law_of_cosines_distance_from(@point3)
    assert_equal(141.3465338444991, distance)
  end
end
