require 'minitest/autorun'
require 'gpx'

class MagellanTest < Minitest::Test
   MAGELLAN_TRACK_LOG = File.join(File.dirname(__FILE__), "gpx_files/magellan_track.log")
   GPX_FILE = File.join(File.dirname(__FILE__), "gpx_files/one_segment.gpx")

   def test_convert
      GPX::MagellanTrackLog.convert_to_gpx(MAGELLAN_TRACK_LOG, "/tmp/gpx_from_magellan.gpx")
      @gpx_file = GPX::GPXFile.new(:gpx_file => "/tmp/gpx_from_magellan.gpx")
   end

   def test_file_type
      assert(GPX::MagellanTrackLog::is_magellan_file?(MAGELLAN_TRACK_LOG))
      assert(!GPX::MagellanTrackLog::is_magellan_file?(GPX_FILE))
   end

end
