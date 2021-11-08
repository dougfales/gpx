# frozen_string_literal: true

module GPX
  class GPXFile < Base
    attr_accessor :tracks,
                  :routes, :waypoints, :bounds, :lowest_point, :highest_point, :duration, :ns, :time, :name, :version, :creator, :description, :moving_duration

    DEFAULT_CREATOR = "GPX RubyGem #{GPX::VERSION} -- http://dougfales.github.io/gpx/"

    # This initializer can be used to create a new GPXFile from an existing
    # file or to create a new GPXFile instance with no data (so that you can
    # add tracks and points and write it out to a new file later).
    # To read an existing GPX file, do this:
    #         gpx_file = GPXFile.new(:gpx_file => 'mygpxfile.gpx')
    #         puts "Speed: #{gpx_file.average_speed}"
    #         puts "Duration: #{gpx_file.duration}"
    #         puts "Bounds: #{gpx_file.bounds}"
    #
    # To read a GPX file from a string, use :gpx_data.
    #         gpx_file = GPXFile.new(:gpx_data => '<xml ...><gpx>...</gpx>)
    # To create a new blank GPXFile instance:
    #         gpx_file = GPXFile.new
    # Note that you can pass in any instance variables to this form of the initializer, including Tracks or Segments:
    #         some_track = get_track_from_csv('some_other_format.csv')
    #         gpx_file = GPXFile.new(:tracks => [some_track])
    #
    def initialize(opts = {})
      super()
      @duration = 0
      @attributes = {}
      @namespace_defs = []
      @tracks = []
      @time = nil

      if opts[:gpx_file] || opts[:gpx_data]
        if opts[:gpx_file]
          gpx_file = opts[:gpx_file]
          gpx_file = File.open(gpx_file) unless gpx_file.is_a?(File)
          @xml = Nokogiri::XML(gpx_file)
        else
          @xml = Nokogiri::XML(opts[:gpx_data])
        end

        gpx_element = @xml.at('gpx')
        @attributes = gpx_element.attributes
        @namespace_defs = gpx_element.namespace_definitions
        @version = gpx_element['version']
        reset_meta_data
        bounds_element = (
        begin
          @xml.at('metadata/bounds')
        rescue StandardError
          nil
        end)
        if bounds_element
          @bounds.min_lat = get_bounds_attr_value(bounds_element, %w[min_lat minlat minLat])
          @bounds.min_lon = get_bounds_attr_value(bounds_element, %w[min_lon minlon minLon])
          @bounds.max_lat = get_bounds_attr_value(bounds_element, %w[max_lat maxlat maxLat])
          @bounds.max_lon = get_bounds_attr_value(bounds_element, %w[max_lon maxlon maxLon])
        else
          get_bounds = true
        end

        @time = begin
          Time.parse(@xml.at('metadata/time').inner_text)
        rescue StandardError
          nil
        end
        @name = begin
          @xml.at('metadata/name').inner_text
        rescue StandardError
          nil
        end
        @description = begin
          @xml.at('metadata/desc').inner_text
        rescue StandardError
          nil
        end
        @xml.search('trk').each do |trk|
          trk = Track.new(element: trk, gpx_file: self)
          update_meta_data(trk, get_bounds)
          @tracks << trk
        end
        @waypoints = []
        @xml.search('wpt').each { |wpt| @waypoints << Waypoint.new(element: wpt, gpx_file: self) }
        @routes = []
        @xml.search('rte').each { |rte| @routes << Route.new(element: rte, gpx_file: self) }
        @tracks.delete_if(&:empty?)

        calculate_duration
      else
        reset_meta_data
        opts.each { |attr_name, value| instance_variable_set("@#{attr_name}", value) }
        unless @tracks.nil? || @tracks.size.zero?
          @tracks.each { |trk| update_meta_data(trk) }
          calculate_duration
        end
      end
      @tracks ||= []
      @routes ||= []
      @waypoints ||= []
    end

    def get_bounds_attr_value(el, possible_names)
      result = nil
      possible_names.each do |name|
        result = el[name]
        break unless result.nil?
      end
      (
      begin
        result.to_f
      rescue StandardError
        nil
      end)
    end

    # Returns the distance, in kilometers, meters, or miles, of all of the
    # tracks and segments contained in this GPXFile.
    def distance(opts = { units: 'kilometers' })
      case opts[:units]
      when /kilometers/i
        @distance
      when /meters/i
        (@distance * 1000)
      when /miles/i
        (@distance * 0.62)
      end
    end

    # Returns the average speed, in km/hr, meters/hr, or miles/hr, of this
    # GPXFile.  The calculation is based on the total distance divided by the
    # sum of duration of all segments of all tracks
    # (not taking into accounting pause time).
    def average_speed(opts = { units: 'kilometers' })
      case opts[:units]
      when /kilometers/i
        distance / (moving_duration / 3600.0)
      when /meters/i
        (distance * 1000) / (moving_duration / 3600.0)
      when /miles/i
        (distance * 0.62) / (moving_duration / 3600.0)
      end
    end

    # Crops any points falling within a rectangular area.  Identical to the
    # delete_area method in every respect except that the points outside of
    # the given area are deleted.  Note that this method automatically causes
    # the meta data to be updated after deletion.
    def crop(area)
      reset_meta_data
      keep_tracks = []
      tracks.each do |trk|
        trk.crop(area)
        unless trk.empty?
          update_meta_data(trk)
          keep_tracks << trk
        end
      end
      @tracks = keep_tracks
      routes.each { |rte| rte.crop(area) }
      waypoints.each { |wpt| wpt.crop(area) }
    end

    # Deletes any points falling within a rectangular area.  The "area"
    # parameter is usually an instance of the Bounds class.  Note that this
    # method cascades into similarly named methods of subordinate classes
    # (i.e. Track, Segment), which means, if you want the deletion to apply
    # to all the data, you only call this one (and not the one in Track or
    # Segment classes).  Note that this method automatically causes the meta
    # data to be updated after deletion.
    def delete_area(area)
      reset_meta_data
      keep_tracks = []
      tracks.each do |trk|
        trk.delete_area(area)
        unless trk.empty?
          update_meta_data(trk)
          keep_tracks << trk
        end
      end
      @tracks = keep_tracks
      routes.each { |rte| rte.delete_area(area) }
      waypoints.each { |wpt| wpt.delete_area(area) }
    end

    # Resets the meta data for this GPX file.  Meta data includes the bounds,
    # the high and low points, and the distance.
    def reset_meta_data
      @bounds = Bounds.new
      @highest_point = nil
      @lowest_point = nil
      @distance = 0.0
      @moving_duration = 0.0
    end

    # rubocop:disable Style/OptionalBooleanParameter

    # Updates the meta data for this GPX file.  Meta data includes the
    # bounds, the high and low points, and the distance.  This is useful when
    # you modify the GPX data (i.e. by adding or deleting points) and you
    # want the meta data to accurately reflect the new data.
    def update_meta_data(trk, get_bounds = true)
      @lowest_point = trk.lowest_point if @lowest_point.nil? || (!trk.lowest_point.nil? && (trk.lowest_point.elevation < @lowest_point.elevation))
      @highest_point = trk.highest_point if @highest_point.nil? || (!trk.highest_point.nil? && (trk.highest_point.elevation > @highest_point.elevation))
      @bounds.add(trk.bounds) if get_bounds
      @distance += trk.distance
      @moving_duration += trk.moving_duration
    end

    # Serialize the current GPXFile to a gpx file named <filename>.
    # If the file does not exist, it is created.  If it does exist, it is overwritten.
    def write(filename, update_time = true)
      @time = Time.now if @time.nil? || update_time
      @name ||= File.basename(filename)
      doc = generate_xml_doc
      File.open(filename, 'w+') { |f| f.write(doc.to_xml) }
    end

    def to_s(update_time = true)
      @time = Time.now if @time.nil? || update_time
      doc = generate_xml_doc
      doc.to_xml
    end
    # rubocop:enable Style/OptionalBooleanParameter

    def inspect
      "<#{self.class.name}:...>"
    end

    def recalculate_distance
      @distance = 0
      @tracks.each do |track|
        track.recalculate_distance
        @distance += track.distance
      end
    end

    private

    def attributes_and_nsdefs_as_gpx_attributes
      # $stderr.puts @namespace_defs.inspect
      gpx_header = {}
      @attributes.each do |k, v|
        k = "#{v.namespace.prefix}:#{k}" if v.namespace
        gpx_header[k] = v.value
      end

      @namespace_defs.each do |nsd|
        tag = 'xmlns'
        tag += ":#{nsd.prefix}" if nsd.prefix
        gpx_header[tag] = nsd.href
      end
      gpx_header
    end

    def generate_xml_doc
      @version ||= '1.1'
      version_dir = version.tr('.', '/')

      gpx_header = attributes_and_nsdefs_as_gpx_attributes

      gpx_header['version'] = @version.to_s unless gpx_header['version']
      gpx_header['creator'] = DEFAULT_CREATOR unless gpx_header['creator']
      gpx_header['xsi:schemaLocation'] = "http://www.topografix.com/GPX/#{version_dir} http://www.topografix.com/GPX/#{version_dir}/gpx.xsd" unless gpx_header['xsi:schemaLocation']
      gpx_header['xmlns:xsi'] = 'http://www.w3.org/2001/XMLSchema-instance' if !gpx_header['xsi'] && !gpx_header['xmlns:xsi']

      # $stderr.puts gpx_header.keys.inspect

      # rubocop:disable Metrics/BlockLength
      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.gpx(gpx_header) do
          # version 1.0 of the schema doesn't support the metadata element, so push them straight to the root 'gpx' element
          if @version == '1.0'
            xml.name @name
            xml.time @time.xmlschema
            xml.bound(
              minlat: bounds.min_lat,
              minlon: bounds.min_lon,
              maxlat: bounds.max_lat,
              maxlon: bounds.max_lon
            )
          else
            xml.metadata do
              xml.name @name
              xml.time @time.xmlschema
              xml.bound(
                minlat: bounds.min_lat,
                minlon: bounds.min_lon,
                maxlat: bounds.max_lat,
                maxlon: bounds.max_lon
              )
            end
          end

          tracks&.each do |t|
            xml.trk do
              xml.name t.name

              t.segments.each do |seg|
                xml.trkseg do
                  seg.points.each do |p|
                    xml.trkpt(lat: p.lat, lon: p.lon) do
                      xml.time p.time.xmlschema unless p.time.nil?
                      xml.ele p.elevation unless p.elevation.nil?
                      xml << p.extensions.to_xml unless p.extensions.nil?
                    end
                  end
                end
              end
            end
          end

          waypoints&.each do |w|
            xml.wpt(lat: w.lat, lon: w.lon) do
              xml.time w.time.xmlschema unless w.time.nil?
              Waypoint::SUB_ELEMENTS.each do |sub_elem|
                xml.send(sub_elem, w.send(sub_elem)) if w.respond_to?(sub_elem) && !w.send(sub_elem).nil?
              end
            end
          end

          routes&.each do |r|
            xml.rte do
              xml.name r.name

              r.points.each do |p|
                xml.rtept(lat: p.lat, lon: p.lon) do
                  xml.time p.time.xmlschema unless p.time.nil?
                  xml.ele p.elevation unless p.elevation.nil?
                end
              end
            end
          end
        end
      end
      # rubocop:enable Metrics/BlockLength
    end

    # Calculates and sets the duration attribute by subtracting the time on
    # the very first point from the time on the very last point.
    def calculate_duration
      @duration = 0
      if @tracks.nil? || @tracks.size.zero? || @tracks[0].segments.nil? || @tracks[0].segments.size.zero?
        return @duration

      end

      @duration = (@tracks[-1].segments[-1].points[-1].time - @tracks.first.segments.first.points.first.time)
    rescue StandardError
      @duration = 0
    end
  end
end
