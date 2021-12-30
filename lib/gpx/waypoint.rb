# frozen_string_literal: true

module GPX
  # This class supports the concept of a waypoint.  Beware that this class has
  # not seen much use yet, since WalkingBoss does not use waypoints right now.
  class Waypoint < Point
    SUB_ELEMENTS = %w[ele magvar geoidheight name cmt desc src link sym type fix sat hdop vdop pdop ageofdgpsdata dgpsid extensions].freeze

    attr_reader :gpx_file

    SUB_ELEMENTS.each { |sub_el| attr_accessor sub_el.to_sym }

    # Not implemented
    def crop(area); end

    # Not implemented
    def delete_area(area); end

    # Initializes a waypoint from a XML::Node.
    def initialize(opts = {})
      if opts[:element] && opts[:gpx_file]
        wpt_elem = opts[:element]
        @gpx_file = opts[:gpx_file]
        super(element: wpt_elem, gpx_file: @gpx_file)
        instantiate_with_text_elements(wpt_elem, SUB_ELEMENTS)
      else
        opts.each do |key, value|
          assignment_method = "#{key}="
          send(assignment_method, value) if respond_to?(assignment_method)
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
        val = send(sub_element_attribute)
        result << "\t#{sub_element_attribute}: #{val}\n" unless val.nil?
      end
      result
    end
  end
end
