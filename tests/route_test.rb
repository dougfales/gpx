require 'minitest/autorun'
require 'gpx'

class RouteTest < Minitest::Test

  def test_read_routes
    gpx = GPX::GPXFile.new(:gpx_file => File.join(File.dirname(__FILE__), "gpx_files/routes.gpx"))
    assert_equal(2, gpx.routes.size)
    first_route = gpx.routes.first
    assert_equal(3, first_route.points.size)
    assert_equal('GRG-CA-TO', first_route.name)


# Route 1, First Point
# <rtept lat="39.997298" lon="-105.292674">
#  <name><![CDATA[GRG-CA]]></name>
#  <sym>Waypoint</sym>
#  <ele>1766.535</ele>
# </rtept>
    assert_equal(39.997298,   first_route.points[0].lat)
    assert_equal(-105.292674, first_route.points[0].lon)
    assert_equal(1766.535,    first_route.points[0].elevation)


# Route 1, Second Point
# <rtept lat="39.995700" lon="-105.292805">
#  <name><![CDATA[AMPTHT]]></name>
#  <sym>Waypoint</sym>
#  <ele>1854.735</ele>
# </rtept>
    assert_equal(39.995700,   first_route.points[1].lat)
    assert_equal(-105.292805, first_route.points[1].lon)
    assert_equal(1854.735,    first_route.points[1].elevation)

# Route 1, Third Point
# <rtept lat="39.989739" lon="-105.295285">
#  <name><![CDATA[TO]]></name>
#  <sym>Waypoint</sym>
#  <ele>2163.556</ele>
# </rtept>
    assert_equal(39.989739,   first_route.points[2].lat)
    assert_equal(-105.295285, first_route.points[2].lon)
    assert_equal(2163.556,    first_route.points[2].elevation)


    second_route = gpx.routes[1]
    assert_equal(1, second_route.points.size)
    assert_equal('SBDR-SBDR', second_route.name)

# Route 2, Only Point
# <rtept lat="39.999840" lon="-105.214696">
#   <name><![CDATA[SBDR]]></name>
#   <sym>Waypoint</sym>
#   <ele>1612.965</ele>
# </rtept>
    assert_equal(39.999840,   second_route.points[0].lat)
    assert_equal(-105.214696, second_route.points[0].lon)
    assert_equal(1612.965,    second_route.points[0].elevation)

  end


end
