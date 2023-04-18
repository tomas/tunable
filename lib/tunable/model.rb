require 'active_support/concern'
require 'tunable/setting'
require 'tunable/hasher'

module Tunable

  COLUMNS = [:context, :key, :value, :settable_id, :settable_type]

  module Model
    extend ActiveSupport::Concern

    included do
      # class variables for main settings and defaults
      class_variable_set('@@main_settings', [])
      class_variable_set('@@default_settings', {})

      # declare relationship
      has_many :settings, :class_name => "Tunable::Setting", :as => :settable, :dependent => :delete_all

      # and make sure settings are saved after any changes
      after_save :save_new_settings
    end

    module ClassMethods

      def default_settings(context)
        class_variable_get('@@default_settings')[context.to_sym] || {}
      end

      def main_settings_list
        class_variable_get('@@main_settings')
      end

      def set_default_setting(key, field, value)
        hash = class_variable_get('@@default_settings')
        hash[key.to_sym] = {} unless hash[key.to_sym]
        hash[key.to_sym][field.to_sym] = value

        class_variable_set('@@default_settings', hash)
      end

      def has_settings(contexts)

        contexts.each do |name, options|

          if options.is_a?(Array)
            res = {}
            options.each { |el| res[el.keys.first] = el.values.first }
          else
            res = options
          end

          res.each do |field, opts|
            if opts.is_a?(Hash)
              default = opts[:default]
            else
              default = opts
            end

            getter = "#{name}_#{field}"

            define_method getter do
              get_setting(name, field)
            end

            define_method "#{getter}=" do |value|
              # self.settings = { name => { field => val } }
              set_setting(name, field, value)
            end

            set_default_setting(name, field, default) unless default.nil?
          end
        end

      end

      def main_settings(*options)

        if options[0].is_a?(Hash)
          fields = options[0]
        else # no defaults
          fields = {}
          options.each { |key| fields[key] = {} }
        end

        fields.each do |field, opts|

          if opts.is_a?(Hash)
            strict  = opts[:strict]
            default = opts[:default]
          else
            default = opts
            strict = false
          end

          main_settings_list.push(field)
          set_default_setting(:main, field, default) unless default.nil?

          define_method field do
            get_value_for(field)
          end

          define_method "#{field}?" do
            main_setting_on?(field.to_sym)
          end

          define_method "#{field}_changed?" do
            changes[field.to_sym].present?
          end

          define_method "#{field}=" do |raw_value|

            if strict && !default.nil? && !Tunable.matching_type(raw_value, default)
              raise "Invalid value: #{raw_value}. Expected #{default.class}, got #{raw_value.class}"
            end

            value   = Tunable.normalize_value(raw_value)
            current = Tunable.normalize_value(get_value_for(field, false)) # don't fallback to default
            # debug "Setting #{field} to #{value} (#{value.class}), current: #{current} (#{current.class})"

            if value === current
              # puts 'Value is same as current'
              changed_attributes.delete(field) # in case we had set if before
              return
            end

            instance_variable_set("@setting_main_#{field}", value)

            if value.nil?
              main_settings.delete(field.to_sym)
              queue_setting_for_deletion(:main, field)
            else
              main_settings[field.to_sym] = value
              queue_setting_for_update(:main, field, value)
            end
          end

        end

      end # main_settings

    end # ClassMethods

    # instance methods below

    def settings=(hash)
      Tunable::Setting.store_many(hash, self)
    end

    def settings_hash
      if modified_settings.any?
        puts "Settings have been changed. Hash will be incomplete."
      end

      @object_hashed_settings ||= Hasher.flatten(settings.reload, :context, :key)
    end

    def get_setting(context, key)
      val = settings_context(context)[key]

      # if value is nil or no default is set, stop here
      return val if !val.nil? or self.class.default_settings(context)[key.to_sym].nil?

      self.class.default_settings(context)[key.to_sym]
    end

    def set_setting(context, key, val)
      obj = { context => { key => val } }
      self.settings = obj
    end

    def remove_setting(context, key)
      set_setting(context, key, nil)
    end

    def get_main_setting(key)
      get_setting(:main, key)
    end

    def settings_context(context)
      settings_hash[context.to_sym] || {}
    end

    def main_settings
      settings_context(:main)
    end

    def clear_instance_settings
      @object_hashed_settings = nil
      @settings = nil # so settings get reloaded from DB
    end

    def setting_off?(context, key)
      get_setting(context, key) == false
    end

    def setting_on?(context, key)
      get_setting(context, key) == true
    end

    def queue_setting_for_update(context, key, val)
      if self.class.main_settings_list.include?(key.to_sym)
        changed_attributes[key.to_sym] = val if changed_attributes.include?(key.to_sym)
      end
      (modified_settings[context.to_sym] ||= {})[key.to_sym] = val
    end

    def queue_setting_for_deletion(context, key)
      if self.class.main_settings_list.include?(key)
        changed_attributes[key.to_sym] = nil if changed_attributes.include?(key.to_sym)
      end
      (deleted_settings[context.to_sym] ||= []) << key.to_sym
    end

    private

    def get_value_for(field, use_default = true)
      if instance_variable_defined?("@setting_main_#{field}")
        # the instance var is already normalized to 1/0 when called by the setter
        Tunable.getter_value(instance_variable_get("@setting_main_#{field}"))
      else
        current = main_settings[field.to_sym]
        return current if current.present? or !use_default

        if default = self.class.default_settings(:main)[field.to_sym]
          return default.is_a?(Proc) ? default.call(self) : default
        end

        nil
      end
    end

    def modified_settings
      @modified_settings ||= {}
    end

    def deleted_settings
      @deleted_settings ||= {}
    end

    def delete_setting(context, key)
      Tunable::Setting.where(
        context: context.to_s,
        key: key.to_s,
        settable_type: self.class.model_name.to_s,
        settable_id: self.id
      ).delete_all
    end

    def save_new_settings

      if modified_settings.any?
        # debug "Saving new settings: #{modified_settings.inspect}"
        new_settings = []

        modified_settings.each do |context, fields|
          fields.each do |key, value|
            # even though we do normalize on the setters, not all settings are
            # main settings, so we need to make sure we normalize here again
            normalized_value = Tunable.normalize_value(value)

            # class.base_class returns name of parent class for STI models
            new_settings << [context.to_s, key.to_s, normalized_value, self.id, self.class.base_class.name]
            # remove_instance_variable("@setting_main_#{key}") if context == :main
          end
        end

        Tunable::Setting.import(Tunable::COLUMNS, new_settings, { :method => 'REPLACE' }) # from lib/core_ext
      end

      if deleted_settings.any?
        # puts deleted_settings.inspect
        deleted_settings.each do |context, fields|
          fields.each do |key|
            delete_setting(context.to_s, key.to_s)
            # remove_instance_variable("@setting_main_#{key}") if context == :main
          end
        end
      end

      self.clear_instance_settings
      @modified_settings = {}
      @deleted_settings = {}

      true # make sure the other callbacks are triggered
    end

  end

end
