ActiveRecord::Schema.define :version => 0 do
  create_table "settings", :force => true do |t|
    t.integer  "settable_id",   :limit => 11
    t.string   "settable_type"
    t.string   "context"
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
  end

  add_index "settings", ["settable_id", "context", "key"], name: "index_settings_on_settable_id_and_context_and_key", unique: true, using: :btree
  add_index "settings", ["settable_id", "settable_type"], name: "index_settings_on_settable_id_and_settable_type", using: :btree

  create_table :tunable_models, :force => true do |t|
    t.column :name, :string
  end
end
