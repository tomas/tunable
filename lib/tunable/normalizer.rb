module Tunable

  module Normalizer

    TRUTHIES = ['true', 't', 'on', 'yes', 'y', '1'].freeze
    FALSIES  = ['false', 'f', 'off', 'no', 'n', '0'].freeze

    def normalize_value(val)
      return 1 if TRUTHIES.include?(val.to_s)
      return 0 if FALSIES.include?(val.to_s)
      return Integer(val) if is_integer?(val)
      return if val.blank? # false.blank? returns true so this needs to go after the 0 line
      val
    end

    def getter_value(normalized)
      return normalized === 1 ? true : normalized === 0 ? false : normalized
    end

    # Called from Setting#normalized_value and DeviceActions#toggle_action
    def normalize_and_get(val)
      getter_value(normalize_value(val))
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
