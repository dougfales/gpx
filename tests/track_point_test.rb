require 'minitest/autorun'
require 'gpx'

class TrackPointTest < Minitest::Test
  def setup
    @point1 = GPX::TrackPoint.new({
      :lat => 37.7985474,
      :lon => -122.2554386
    })
    @point2 = GPX::TrackPoint.new({
      :lat => 37.7985583,
      :lon => -122.2554564
    })
  end

  def test_haversine_distance_from
    distance = @point1.haversine_distance_from(@point2)
    assert_equal(0.00197862991592239, distance)
  end

  def test_pythagorean_distance_from
    distance = @point1.pythagorean_distance_from(@point2)
    assert_equal(3.642891416092969e-07, distance)
  end

  def test_law_of_cosines_distance_from
    distance = @point1.law_of_cosines_distance_from(@point2)
    assert_equal(0.001982307218559664, distance)
  end
end
