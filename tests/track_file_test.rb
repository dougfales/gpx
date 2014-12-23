require 'minitest/autorun'
require 'gpx'

class TrackFileTest < Minitest::Test
   TRACK_FILE = File.join(File.dirname(__FILE__), "gpx_files/tracks.gpx")
   OTHER_TRACK_FILE = File.join(File.dirname(__FILE__), "gpx_files/arches.gpx")

   def setup
      @track_file = GPX::GPXFile.new(:gpx_file => TRACK_FILE)
      @other_track_file = GPX::GPXFile.new(:gpx_file => OTHER_TRACK_FILE)
   end

   def test_track_read
      assert_equal(3, @track_file.tracks.size)
      assert_equal("First Track",  @track_file.tracks[0].name)
      assert_equal("Second Track", @track_file.tracks[1].name)
      assert_equal("Third Track",  @track_file.tracks[2].name)
   end

   def test_track_segment_and_point_counts
      # One segment with 398 points...
      assert_equal(1, @track_file.tracks[0].segments.size)
      assert_equal(389, @track_file.tracks[0].segments.first.points.size)

      # One segment with 299 points...
      assert_equal(1, @track_file.tracks[1].segments.size)
      assert_equal(299, @track_file.tracks[1].segments.first.points.size)

      # Many segments of many different sizes
      segment_sizes = %w{ 2 2 5 4 2 1 197 31 54 1 15 54 19 26 109 18 9 2 8 3 10 23 21 11 25 32 66 21 2 3 3 4 6 4 4 4 3 3 6 6 27 13 2 }
      assert_equal(43, @track_file.tracks[2].segments.size)
      @track_file.tracks[2].segments.each_with_index do |seg, i|
         assert_equal(segment_sizes[i].to_i, seg.points.size)
      end
      last_segment = @track_file.tracks[2].segments.last
      assert_equal(1680.041, last_segment.points.last.elevation)


      second_to_last_segment = @track_file.tracks[2].segments[-2]
      assert_equal("2006-01-02T00:00:51Z", second_to_last_segment.points.last.time.strftime("%Y-%m-%dT%H:%M:%SZ"))
      assert_equal(39.998045, second_to_last_segment.points.last.lat)
      assert_equal(-105.292368, second_to_last_segment.points.last.lon)
   end

   def test_find_nearest_point_by_time
      time = Time.parse("2005-12-31T22:02:01Z")
      pt = @track_file.tracks[0].closest_point(time)
      #puts "pt: #{pt.lat_lon}"

   end

   def test_find_distance
      #puts "Distance: #{@other_track_file.distance(:units => 'miles')} miles"
      #puts "Distance: #{@track_file.distance(:units => 'miles')} miles"
   end
   def test_high_low_elevation
      #puts "Lowest: #{@track_file.lowest_point.elevation} m"
      #puts "Highest: #{@track_file.highest_point.elevation} m"
   end

   def test_duration
      #puts "Duration 1: #{@other_track_file.duration} "
      #puts "Duration 2: #{@track_file.duration} "
   end

   def test_average_speed
      #puts "Speed 1: #{@other_track_file.average_speed} "
      #puts "Speed 2: #{@track_file.average_speed} "
   end

   def test_write
      @other_track_file.write("tests/output/myoutput.gpx")
   end

end
