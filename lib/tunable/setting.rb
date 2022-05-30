require 'tunable/core_ext'

module Tunable

  class Setting < ActiveRecord::Base
    extend ActiveRecordExtensions

    belongs_to :settable, :polymorphic => true

    # scope :for_context, lambda { |context|
    #   return if context.blank?
    #   where(:context => context)
    # }

    # scope :main, lambda { where(:context => 'main') }

    # scope :get, lambda { |key|
    #   return if key.blank?
    #   where(:key => key)
    # }

    # this method regenerates all settings when updating a device.
    # we first remove all the settings (we dont get params from disabled modules)
    def self.store_many(hash, object)
      wipe_all(object) and return if hash.blank?

      hash.each do |context, fields|
        fields.each do |key, val|
          if val.blank? && !object.settings_context(context.to_sym)[key.to_sym].nil?

            # setting was present and now deleted
            object.queue_setting_for_deletion(context, key)

          elsif val != object.settings_context(context.to_sym)[key.to_sym]

            # settings different from previous, so update
            object.queue_setting_for_update(context, key, val)
          end
        end
      end
    end

    def self.wipe_all(object)
      count = object.settings.where("`context` != 'main'").delete_all
      # debug "#{count} deleted settings."
      true
    end

    def normalized_value
      Tunable.normalize_and_get(self[:value])
    end

    def value=(val)
      self[:value] = Tunable.normalize_value(val)
    end

  end

end
