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

require 'time'
require 'nokogiri'

require File.expand_path('../gpx/version', __FILE__)

require File.expand_path('../gpx/gpx', __FILE__)
require File.expand_path('../gpx/gpx_file', __FILE__)
require File.expand_path('../gpx/bounds', __FILE__)
require File.expand_path('../gpx/track', __FILE__)
require File.expand_path('../gpx/route', __FILE__)
require File.expand_path('../gpx/segment', __FILE__)
require File.expand_path('../gpx/point', __FILE__)
require File.expand_path('../gpx/trackpoint', __FILE__)
require File.expand_path('../gpx/waypoint', __FILE__)
require File.expand_path('../gpx/magellan_track_log', __FILE__)
