require 'minitest/autorun'
require 'gpx'

class TrackFileTest < Minitest::Test
  TRACK_FILE = File.join(File.dirname(__FILE__), 'gpx_files/tracks.gpx')
  OTHER_TRACK_FILE = File.join(File.dirname(__FILE__), 'gpx_files/arches.gpx')

  def setup
    @track_file = GPX::GPXFile.new(gpx_file: TRACK_FILE)
    @other_track_file = GPX::GPXFile.new(gpx_file: OTHER_TRACK_FILE)
  end

  def test_track_read
    assert_equal(3, @track_file.tracks.size)
    assert_equal('First Track',  @track_file.tracks[0].name)
    assert_equal('Second Track', @track_file.tracks[1].name)
    assert_equal('Third Track',  @track_file.tracks[2].name)
  end

  def test_track_segment_and_point_counts
    # One segment with 398 points...
    assert_equal(1, @track_file.tracks[0].segments.size)
    assert_equal(389, @track_file.tracks[0].segments.first.points.size)

    # One segment with 299 points...
    assert_equal(1, @track_file.tracks[1].segments.size)
    assert_equal(299, @track_file.tracks[1].segments.first.points.size)

    # Many segments of many different sizes
    segment_sizes = %w[2 2 5 4 2 1 197 31 54 1 15 54 19 26 109 18 9 2 8 3 10 23 21 11 25 32 66 21 2 3 3 4 6 4 4 4 3 3 6 6 27 13 2]
    assert_equal(43, @track_file.tracks[2].segments.size)
    @track_file.tracks[2].segments.each_with_index do |seg, i|
      assert_equal(segment_sizes[i].to_i, seg.points.size)
    end
    last_segment = @track_file.tracks[2].segments.last
    assert_equal(1680.041, last_segment.points.last.elevation)

    second_to_last_segment = @track_file.tracks[2].segments[-2]
    assert_equal('2006-01-02T00:00:51Z', second_to_last_segment.points.last.time.strftime('%Y-%m-%dT%H:%M:%SZ'))
    assert_equal(39.998045, second_to_last_segment.points.last.lat)
    assert_equal(-105.292368, second_to_last_segment.points.last.lon)
  end

  def test_write
    output_path = 'tests/output/myoutput.gpx'
    @other_track_file.write(output_path)
    new_track_file = GPX::GPXFile.new(gpx_file: output_path)
    orig_segments = @other_track_file.tracks.first.segments
    new_segments = new_track_file.tracks.first.segments
    assert_equal(orig_segments.first.points.map(&:lat_lon), new_segments.first.points.map(&:lat_lon))
  end
end
