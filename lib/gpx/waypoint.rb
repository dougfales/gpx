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

    SUB_ELEMENTS = %w{ele magvar geoidheight name cmt desc src link sym type fix sat hdop vdop pdop ageofdgpsdata dgpsid extensions}

    attr_reader :gpx_file
    SUB_ELEMENTS.each { |sub_el| attr_accessor sub_el.to_sym }

    # Not implemented
    def crop(area)
    end

    # Not implemented
    def delete_area(area)
    end

    # Initializes a waypoint from a XML::Node.
    def initialize(opts = {})
      if(opts[:element] and opts[:gpx_file])
        wpt_elem = opts[:element]
        @gpx_file = opts[:gpx_file]
        super(:element => wpt_elem, :gpx_file => @gpx_file)
        instantiate_with_text_elements(wpt_elem, SUB_ELEMENTS)
      else
        opts.each do |key, value|
          assignment_method = "#{key}="
          if self.respond_to?(assignment_method)
            self.send(assignment_method, value)
          end
        end
      end
    end

    # Prints out a friendly summary of this track (sans points).  Useful for
    # debugging and sanity checks.
    def to_s
      result = "Waypoint \n"
      result << "\tName: #{name}\n"
      result << "\tLatitude: #{lat} \n"
      result << "\tLongitude: #{lon} \n"
      result << "\tElevation: #{elevation}\n "
      result << "\tTime: #{time}\n"
      SUB_ELEMENTS.each do |sub_element_attribute|
        val = self.send(sub_element_attribute)
        result << "\t#{sub_element_attribute}: #{val}\n" unless val.nil?
      end
      result
    end
  end
end
