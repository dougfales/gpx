require 'minitest/autorun'
require 'gpx'

class WaypointTest < Minitest::Test

  def test_read_waypoints

    gpx = GPX::GPXFile.new(:gpx_file => File.join(File.dirname(__FILE__), "gpx_files/waypoints.gpx"))
    assert_equal(18, gpx.waypoints.size)

    #    First Waypoint
    #   <wpt lat="40.035557" lon="-105.248268">
    #   <name><![CDATA[001]]></name>
    #   <sym>Waypoint</sym>
    #   <ele>1639.161</ele>
    #   <cmt><![CDATA[001]]></cmt>
    #   <desc><![CDATA[Just some waypoint...]]></desc>
    #   </wpt>

    first_wpt = gpx.waypoints[0]
    assert_equal(40.035557, first_wpt.lat)
    assert_equal(-105.248268, first_wpt.lon)
    assert_equal('001', first_wpt.name)
    assert_equal('001', first_wpt.cmt)
    assert_equal('Just some waypoint...', first_wpt.desc)
    assert_equal('Waypoint', first_wpt.sym)
  	assert_equal(1639.161, first_wpt.elevation)

    #    Second Waypoint
    #    <wpt lat="39.993070" lon="-105.296588">
    #    <name><![CDATA[002]]></name>
    #    <sym>Waypoint</sym>
    #    <ele>1955.192</ele>
    #    </wpt>
    second_wpt = gpx.waypoints[1]
    assert_equal(39.993070, second_wpt.lat)
    assert_equal(-105.296588, second_wpt.lon)
    assert_equal('002', second_wpt.name)
    assert_equal('Waypoint', second_wpt.sym)
    assert_equal(1955.192, second_wpt.elevation)
    
    # test loads time properly in waypoint
    time_wpt = gpx.waypoints[17]
    assert_equal(Time.xmlschema("2015-01-01T12:12:12Z"), time_wpt.time)
    
  end
end

