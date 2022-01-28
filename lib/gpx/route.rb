# frozen_string_literal: true

module GPX
  # A Route in GPX is very similar to a Track, but it is created by a user
  # from a series of Waypoints, whereas a Track is created by the GPS device
  # automatically logging your progress at regular intervals.
  class Route < Base
    attr_accessor :points, :name, :gpx_file

    # Initialize a Route from a XML::Node.
    def initialize(opts = {})
      super()
      if opts[:gpx_file] && opts[:element]
        rte_element = opts[:element]
        @gpx_file = opts[:gpx_file]
        @name = rte_element.at('name')&.inner_text
        @points = []
        rte_element.search('rtept').each do |point|
          @points << Point.new(element: point, gpx_file: @gpx_file)
        end
      else
        @points = (opts[:points] || [])
        @name = (opts[:name])
      end
    end

    # Delete points outside of a given area.
    def crop(area)
      points.delete_if { |pt| !area.contains? pt }
    end

    # Delete points within the given area.
    def delete_area(area)
      points.delete_if { |pt| area.contains? pt }
    end
  end
end
