# GPX Gem

[<img src="https://travis-ci.org/dougfales/gpx.svg" alt="Build Status" />](https://travis-ci.org/dougfales/gpx)
[![Code Climate](https://codeclimate.com/github/dougfales/gpx/badges/gpa.svg)](https://codeclimate.com/github/dougfales/gpx)

## What It Does

This library reads GPX files and provides an API for reading and manipulating
the data as objects. For more info on the GPX format, see
http://www.topografix.com/gpx.asp.

In addition to parsing GPX files, this library is capable of converting
Magellan NMEA files to GPX, converting GeoJSON data to GPX, and writing
new GPX files. It can crop and delete rectangular areas within a file,
and it also calculates some meta-data about the tracks and points in a file (such as distance, duration, average speed, etc).

## Requirements

- As of `1.1.1`, `gpx` requires at least Ruby 2.7 to run.
- As of `1.0.0`, `gpx` requires at least Ruby 2.2 to run.

## Installation

Add to your gemfile:

```
gem 'gpx'
```

## Examples

Initialize a `GPXFile` object with either a file-like object or a string representation:

```ruby
gpx = GPX::GPXFile.new(:gpx_file => string_io) # Anything that responds to `read`
gpx = GPX::GPXFile.new(:gpx_file => path_to_a_file)
gpx = GPX::GPXFile.new(:gpx_data => some_string)
```

Reading a GPX file, and cropping its contents to a given area:

```ruby
gpx =  GPX::GPXFile.new(:gpx_file => filename)   # Read GPX file
bounds = GPX::Bounds.new(params)                 # Create a rectangular area to crop
gpx.crop(bounds)                                 # Crop it
gpx.write(filename)                              # Save it
```

Converting a Magellan track log to GPX:

```ruby
if GPX::MagellanTrackLog::is_magellan_file?(filename)
 GPX::MagellanTrackLog::convert_to_gpx(filename, "#{filename}.gpx")
end
```

Converting GeoJSON data to GPX can be achieved by providing a
file path, file, or the data in string format:

```ruby
# Converting from a file name
gpx_file = GPX::GeoJSON.convert_to_gpx(geojson_file: 'mygeojsonfile.json')

# Converting from a string
data = JSON.generate(my_geojson_hash)
gpx_file = GPX::GeoJSON.convert_to_gpx(geojson_data: data)

# The above won't transfer anything but coordinate values. If you want to
# transfer ad hoc "properties" information, you can specify an object that
# responds to `call` to manipulate GPX data structures as follows:
gpx_file = GPX::GeoJSON.convert_to_gpx(
  geojson_data: data,
  line_string_feature_to_segment: ->(ls, seg) { seg.distance = ls["properties"]["distance"] },
  multi_line_string_feature_to_track: lambda { |mls, track|
    track.name = mls["properties"]["name"]
  },
  point_feature_to_waypoint: ->(pt, wpt) { wpt.name = pt["properties"]["name"] }
  multi_point_feature_to_waypoint: ->(mpt, wpt) { wpt.sym = mpt["properties"]["icon"] }
)
```

Exporting an ActiveRecord to GPXFile (as Waypoints)

```ruby
#
# Our active record in this example is called stop
#

# models/stop.rb
class Stop < ActiveRecord::Base
   # This model has the following attributes:
   # name
   # lat
   # lon
   # updated_at

   def self.to_gpx
     require 'GPX'
     gpx = GPX::GPXFile.new
     all.each do |stop|
       gpx.waypoints << GPX::Waypoint.new({name: stop.name, lat: stop.lat, lon: stop.lon, time: stop.updated_at})
     end
     gpx.to_s
   end
 end # class


# controllers/stops.rb
def index
   @stops = Stop.all
   respond_to do |format|
    format.html {render :index}
    format.gpx { send_data @stops.to_gpx, filename: controller_name + '.gpx' }
   end
end


# Add this line to config/initializers/mime_types.rb
Mime::Type.register "application/gpx+xml", :gpx


# To get the xml file:
#   http://localhost:3000/stops.gpx
```

You have a complete example on how to create a gpx file from scratch on `tests/output_text.rb`.

## Notes

This library was written to bridge the gap between my Garmin Geko
and my website, WalkingBoss.org (RIP). For that reason, it has always been more of a
work-in-progress than an attempt at full GPX compliance. The track side of the
library has seen much more use than the route/waypoint side, so if you're doing
something with routes or waypoints, you may need to tweak some things.

Since this code uses XML to read an entire GPX file into memory, it is not
the fastest possible solution for working with GPX data, especially if you are
working with tracks from several days or weeks.

Finally, it should be noted that none of the distance/speed calculation or
crop/delete code has been tested under International Date Line-crossing
conditions. That particular part of the code will likely be unreliable if
you're zig-zagging across 180 degrees longitude routinely.

## License

MIT
