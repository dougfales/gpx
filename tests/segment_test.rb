require 'test/unit'
require File.dirname(__FILE__) + '/../lib/gpx'

class TestSegment < Test::Unit::TestCase
   ONE_SEGMENT = File.join(File.dirname(__FILE__), "gpx_files/one_segment.gpx")

   def setup
      @gpx_file = GPX::GPXFile.new(:gpx_file => ONE_SEGMENT)
      @segment = @gpx_file.tracks.first.segments.first
   end

   def test_segment_read
      assert_equal(189, @segment.points.size)
      assert_equal("Fri Apr 07 18:12:05 UTC 2006", @segment.earliest_point.time.to_s)
      assert_equal("Fri Apr 07 19:26:31 UTC 2006", @segment.latest_point.time.to_s)
      assert_equal(1334.447, @segment.lowest_point.elevation)
      assert_equal(1480.087, @segment.highest_point.elevation)
      assert_equal("6.98803359528853", @segment.distance.to_s) 
   end

   def test_segment_crop
      crop_rectangle = GPX::Bounds.new( :min_lat=> 39.173000,
                                   :min_lon=> -109.010000,
                                   :max_lat=> 39.188000,
                                   :max_lon=> -108.999000)
      @segment.crop(crop_rectangle)

      assert_equal(106, @segment.points.size) 
      assert_equal("4.11422061733046", @segment.distance.to_s) 
      assert_equal("Fri Apr 07 18:37:21 UTC 2006", @segment.earliest_point.time.to_s)
      assert_equal("Fri Apr 07 19:22:32 UTC 2006",  @segment.latest_point.time.to_s)
      assert_equal(1407.027, @segment.lowest_point.elevation)
      assert_equal(1480.087, @segment.highest_point.elevation)
      assert_equal(39.173834, @segment.bounds.min_lat)
      assert_equal(-109.009995, @segment.bounds.min_lon)
      assert_equal(39.187868,   @segment.bounds.max_lat)
      assert_equal(-108.999546, @segment.bounds.max_lon)
   end

   def test_segment_delete
      delete_rectangle = GPX::Bounds.new( :min_lat=> 39.173000,
                                   :min_lon=> -109.010000,
                                   :max_lat=> 39.188000,
                                   :max_lon=> -108.999000)
      @segment.delete_area(delete_rectangle)
      assert_equal(83, @segment.points.size) 
      assert_equal("3.35967118153605", @segment.distance.to_s) 
      assert_equal("Fri Apr 07 18:12:05 UTC 2006", @segment.earliest_point.time.to_s)
      assert_equal("Fri Apr 07 19:26:31 UTC 2006",  @segment.latest_point.time.to_s)
      assert_equal(1334.447, @segment.lowest_point.elevation)
      assert_equal(1428.176, @segment.highest_point.elevation)
      assert_equal(39.180572, @segment.bounds.min_lat)
      assert_equal(-109.016604, @segment.bounds.min_lon)
      assert_equal(39.188747,   @segment.bounds.max_lat)
      assert_equal(-109.007978, @segment.bounds.max_lon)
   end
end
