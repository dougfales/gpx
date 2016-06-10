module GPX
  module Util
    def lower_elevation?(a, b)
      return true if a.nil?
      return false if b.nil?
      b.elevation < a.elevation
    end
    module_function :lower_elevation?

    def higher_elevation?(a, b)
      return true if a.nil?
      return false if b.nil?
      b.elevation > a.elevation
    end
    module_function :higher_elevation?

    def earlier_time?(a, b)
      return true if a.nil?
      return false if b.nil?
      b.time < a.time
    end
    module_function :earlier_time?

    def latter_time?(a, b)
      return true if a.nil?
      return false if b.nil?
      b.time > a.time
    end
    module_function :latter_time?
  end
end
