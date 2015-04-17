class TunableMigration < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.column :context, :string
      t.column :key, :string
      t.column :value, :string

      t.column :settable_id, :integer
      t.column :settable_type, :string
      t.column :created_at, :datetime
    end

    add_index :settings, [:settable_id, :settable_type]
    add_index :settings, [:settable_id, :context, :key], :unique => true
  end

  def self.down
    remove_index :settings, :name => "index_settings_on_settable_id_and_settable_type"
    remove_index :settings, :name => "index_settings_on_settable_id_and_context_and_key"

    drop_table :settings
  end
end
