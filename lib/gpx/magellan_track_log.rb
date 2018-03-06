#--
# Copyright (c) 2006  Doug Fales
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
module GPX
  # This class will parse the lat/lon and time data from a Magellan track log,
  # which is a NMEA formatted CSV list of points.
  class MagellanTrackLog
    # PMGNTRK
    # This message is to be used to transmit Track information (basically a list of previous position fixes)
    # which is often displayed on the plotter or map screen of the unit.  The first field in this message
    # is the Latitude, followed by N or S.  The next field is the Longitude followed by E or W.  The next
    # field is the altitude followed by “F” for feet or “M” for meters.  The next field is
    # the UTC time of the fix.  The next field consists of a status letter of “A” to indicated that
    # the data is valid, or “V” to indicate that the data is not valid.  The last character field is
    # the name of the track, for those units that support named tracks.  The last field contains the UTC date
    # of the fix.  Note that this field is (and its preceding comma) is only produced by the unit when the
    # command PMGNCMD,TRACK,2 is given.  It is not present when a simple command of PMGNCMD,TRACK is issued.

    # NOTE: The Latitude and Longitude Fields are shown as having two decimal
    # places. As many additional decimal places may be added as long as the total
    # length of the message does not exceed 82 bytes.

    # $PMGNTRK,llll.ll,a,yyyyy.yy,a,xxxxx,a,hhmmss.ss,A,c----c,ddmmyy*hh<CR><LF>
    require 'csv'

    LAT       = 1
    LAT_HEMI  = 2
    LON       = 3
    LON_HEMI  = 4
    ELE       = 5
    ELE_UNITS = 6
    TIME      = 7
    INVALID_FLAG = 8
    DATE = 10

    FEET_TO_METERS = 0.3048

    class << self
      # Takes the name of a magellan file, converts the contents to GPX, and
      # writes the result to gpx_filename.
      def convert_to_gpx(magellan_filename, gpx_filename)
        segment = Segment.new

        CSV.open(magellan_filename, 'r').each do |row|
          next if (row.size < 10) || (row[INVALID_FLAG] == 'V')

          lat_deg  = row[LAT][0..1]
          lat_min  = row[LAT][2...-1]
          lat_hemi = row[LAT_HEMI]

          lat = lat_deg.to_f + (lat_min.to_f / 60.0)
          lat = -lat if lat_hemi == 'S'

          lon_deg = row[LON][0..2]
          lon_min  = row[LON][3..-1]
          lon_hemi = row[LON_HEMI]

          lon = lon_deg.to_f + (lon_min.to_f / 60.0)
          lon = -lon if lon_hemi == 'W'

          ele = row[ELE]
          ele_units = row[ELE_UNITS]
          ele = ele.to_f
          ele *= FEET_TO_METERS if ele_units == 'F'

          hrs  = row[TIME][0..1].to_i
          mins = row[TIME][2..3].to_i
          secs = row[TIME][4..5].to_i
          day  = row[DATE][0..1].to_i
          mon  = row[DATE][2..3].to_i
          yr   = 2000 + row[DATE][4..5].to_i

          time = Time.gm(yr, mon, day, hrs, mins, secs)

          # must create point
          pt = TrackPoint.new(lat: lat, lon: lon, time: time, elevation: ele)
          segment.append_point(pt)
        end

        trk = Track.new
        trk.append_segment(segment)
        gpx_file = GPXFile.new(tracks: [trk])
        gpx_file.write(gpx_filename)
      end

      # Tests to see if the given file is a magellan NMEA track log.
      def is_magellan_file?(filename)
        i = 0
        File.open(filename, 'r') do |f|
          f.each do |line|
            i += 1
            if line =~ /^\$PMGNTRK/
              return true
            elsif line =~ /<\?xml/
              return false
            elsif i > 10
              return false
            end
          end
        end
        false
      end
    end
  end
end
