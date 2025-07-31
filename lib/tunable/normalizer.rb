module Tunable

  module Normalizer

    TRUTHIES = ['true', 't', 'on', 'yes', 'y'].freeze
    FALSIES  = ['false', 'f', 'off', 'no', 'n'].freeze

    def normalize_value(val, type = nil)
      # if [TrueClass, FalseClass].include?(type)
      #   return false if val.to_s == '0'
      #   return true if val.to_s == '1'
      # end

      return true if TRUTHIES.include?(val.to_s)
      return false if FALSIES.include?(val.to_s)
      return Integer(val) if is_integer?(val)
      return if val.blank? # false.blank? returns true so this needs to go after the 0 line
      val
    end

    # Called from Setting#normalized_value and DeviceActions#toggle_action
    def normalize_and_get(val)
      normalize_value(val)
    end

    def matching_type(a, b)
      if [true, false].include?(a)
        return [true, false].include?(b)
      else
        a.class == b.class
      end
    end

    private

    def is_integer?(val)
      Integer(val)
      true
    rescue
      false
    end

  end

end
