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

   # This class supports the concept of a waypoint.  Beware that this class has
   # not seen much use yet, since WalkingBoss does not use waypoints right now. 
   class Waypoint < Point

      SUB_ELEMENTS = %w{ magvar geoidheight name cmt desc src link sym type fix sat hdop vdop pdop ageofdgpsdata dgpsid extensions } 

      attr_reader :gpx_file

      # Not implemented
      def crop(area)
      end

      # Not implemented
      def delete_area(area)
      end

      # Initializes a waypoint from a XML::Node.
      def initialize(opts = {})
         wpt_elem = opts[:element]
         @gpx_file = opts[:gpx_file]
         super(:element => wpt_elem, :gpx_file => @gpx_file)
         instantiate_with_text_elements(wpt_elem, SUB_ELEMENTS)
      end

      # Converts a waypoint to a XML::Node.
      def to_xml
         wpt = Node.new('wpt')
         wpt.attributes['lat'] = lat
         wpt.attributes['lon'] = lon
         if self.respond_to? :name
            name_elem = Node.new('name')
            name_elem <<  self.name 
            wpt <<  name_elem
         end
         if self.respond_to? :sym
            sym_elem = Node.new('sym')
            sym_elem <<  self.sym
            wpt <<  sym_elem
         end
         if self.respond_to? :ele
            elev_elem = Node.new('ele')
            elev_elem <<  self.ele
            wpt <<  elev_elem
         end
         wpt
      end
   end
end
