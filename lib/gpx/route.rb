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

   # A Route in GPX is very similar to a Track, but it is created by a user
   # from a series of Waypoints, whereas a Track is created by the GPS device
   # automatically logging your progress at regular intervals.  
   class Route < Base

      attr_accessor :points, :name, :gpx_file

      # Initialize a Route from a XML::Node.
      def initialize(opts = {})
		if(opts[:gpx_file] and opts[:element])
         rte_element = opts[:element]
         @gpx_file = opts[:gpx_file]
         @name = rte_element.at("//name").inner_text
         @points = []
         rte_element.search("//rtept").each do |point|
		   @points << Point.new(:element => point, :gpx_file => @gpx_file)
         end
	   else
		 @points = (opts[:points] or [])
		 @name = (opts[:name])
	   end

      end

      # Delete points outside of a given area.
      def crop(area)
         points.delete_if{ |pt| not area.contains? pt }
      end

      # Delete points within the given area.
      def delete_area(area)
         points.delete_if{ |pt| area.contains? pt }
      end

      # Convert this Route to a XML::Node.
      def to_xml
         rte = Node.new('rte')
         name_elem = Node.new('name')
         name_elem <<  name
         rte <<  name_elem
         points.each { |rte_pt| rte <<  rte_pt.to_xml('rtept') }
         rte
      end

   end
end
