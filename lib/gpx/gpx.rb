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
   VERSION = "0.2"

   # A common base class which provides a useful initializer method to many
   # class in the GPX library.
   class Base
   include XML

      # This initializer can take an XML::Node and scrape out any text
      # elements with the names given in the "text_elements" array.  Each
      # element found underneath "parent" with a name in "text_elements" causes
      # an attribute to be initialized on the instance.  This means you don't
      # have to pick out individual text elements in each initializer of each
      # class (Route, TrackPoint, Track, etc).  Just pass an array of possible
      # attributes to this method.
      def instantiate_with_text_elements(parent, text_elements)
         text_elements.each do |el|
            unless parent.find(el).empty?
               val = parent.find(el).first.content
               code = <<-code
                  attr_accessor #{ el }
                  #{el}=#{val}
               code
               class_eval code
            end
         end

      end

   end
end
