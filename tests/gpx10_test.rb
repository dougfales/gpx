require 'minitest/autorun'
require 'gpx'

class GPX10Test < Minitest::Test
   GPX_FILE = File.join(File.dirname(__FILE__), "gpx_files/gpx10.gpx")

   def test_read
      # make sure we can read a GPX 1.0 file
      @gpx_file = GPX::GPXFile.new(:gpx_file => GPX_FILE)
   end

end
