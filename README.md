# GPX Gem

[<img src="https://travis-ci.org/andrewhao/gpx.svg" alt="Build Status" />](https://travis-ci.org/andrewhao/gpx)
[![Code Climate](https://codeclimate.com/github/andrewhao/gpx/badges/gpa.svg)](https://codeclimate.com/github/andrewhao/gpx)

Copyright (C) 2006 Doug Fales doug@falesafeconsulting.com

## What It Does

This library reads GPX files and provides an API for reading and manipulating
the data as objects.  For more info on the GPX format, see
http://www.topografix.com/gpx.asp.

In addition to parsing GPX files, this library is capable of converting
Magellan NMEA files to GPX, and writing new GPX files.  It can crop and delete
rectangular areas within a file, and it also calculates some meta-data about
the tracks and points in a file (such as distance, duration, average speed,
etc).

## Examples

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
and my website, WalkingBoss.org (RIP).  For that reason, it has always been more of a
work-in-progress than an attempt at full GPX compliance.  The track side of the
library has seen much more use than the route/waypoint side, so if you're doing
something with routes or waypoints, you may need to tweak some things.  

Since this code uses XML to read an entire GPX file into memory, it is not
the fastest possible solution for working with GPX data, especially if you are
working with tracks from several days or weeks.  

Finally, it should be noted that none of the distance/speed calculation or
crop/delete code has been tested under International Date Line-crossing
conditions.  That particular part of the code will likely be unreliable if
you're zig-zagging across 180 degrees longitude routinely.
