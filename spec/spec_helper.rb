$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'bundler/setup'
require 'active_record'
require 'tunable'

ActiveRecord::Base.establish_connection(
  "adapter"  => "sqlite3",
  "database" => ':memory:'
)

ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))

this_path = File.dirname(__FILE__)
load File.join(this_path, '/schema.rb')

class TunableModel < ActiveRecord::Base
  include Tunable::Model
end

def load_main_settings!

  TunableModel.main_settings \
    :boolean_setting,
    :number_setting,
    :empty_setting,
    :on_off_setting,
    :y_n_setting,
    :other_setting

=begin
  TunableModel.main_settings ({
    :boolean_setting => { :default => true },
    :number_setting  => { :default => false },
    :empty_setting   => { },
    :on_off_setting  => { },
    :y_n_setting     => { :default => 'y', :strict => false },
    :other_setting   => { }
  })
=end

end
