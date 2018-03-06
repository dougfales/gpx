module GPX
  # A common base class which provides a useful initializer method to many
  # class in the GPX library.
  class Base
    # This initializer can take an XML::Node and scrape out any text
    # elements with the names given in the "text_elements" array.  Each
    # element found underneath "parent" with a name in "text_elements" causes
    # an attribute to be initialized on the instance.  This means you don't
    # have to pick out individual text elements in each initializer of each
    # class (Route, TrackPoint, Track, etc).  Just pass an array of possible
    # attributes to this method.
    def instantiate_with_text_elements(parent, text_elements)
      text_elements.each do |el|
        child_xpath = el.to_s
        unless parent.at(child_xpath).nil?
          val = parent.at(child_xpath).inner_text
          send("#{el}=", val)
        end
      end
    end
  end
end
