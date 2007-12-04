require 'test/unit'
require File.dirname(__FILE__) + '/../lib/gpx'

class GPXFileTest < Test::Unit::TestCase
  ONE_TRACK_FILE = File.join(File.dirname(__FILE__), "gpx_files/one_track.gpx")
  def test_load_data
    GPX::GPXFile.new(:gpx_data => open(ONE_TRACK_FILE).read)
  end
end
