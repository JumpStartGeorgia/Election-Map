# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120423143932) do

  create_table "data", :force => true do |t|
    t.integer  "indicator_id"
    t.string   "common_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "common_name"
  end

  add_index "data", ["common_id"], :name => "index_data_on_common_id"
  add_index "data", ["common_name"], :name => "index_data_on_common_name"
  add_index "data", ["indicator_id"], :name => "index_data_on_indicator_id"

  create_table "event_translations", :force => true do |t|
    t.integer  "event_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_translations", ["event_id"], :name => "index_event_translations_on_event_id"
  add_index "event_translations", ["locale"], :name => "index_event_translations_on_locale"
  add_index "event_translations", ["name"], :name => "index_event_translations_on_name"

  create_table "event_type_translations", :force => true do |t|
    t.integer  "event_type_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_type_translations", ["event_type_id"], :name => "index_event_type_translations_on_event_type_id"
  add_index "event_type_translations", ["locale"], :name => "index_event_type_translations_on_locale"
  add_index "event_type_translations", ["name"], :name => "index_event_type_translations_on_name"

  create_table "event_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "event_type_id"
    t.integer  "shape_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "event_date"
  end

  add_index "events", ["event_type_id"], :name => "index_events_on_event_type_id"
  add_index "events", ["shape_id"], :name => "index_events_on_shape_id"

  create_table "indicator_scale_translations", :force => true do |t|
    t.integer  "indicator_scale_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "indicator_scale_translations", ["indicator_scale_id"], :name => "index_412234fdb185d426c004e05119f032969291aa2f"
  add_index "indicator_scale_translations", ["locale"], :name => "index_indicator_scale_translations_on_locale"
  add_index "indicator_scale_translations", ["name"], :name => "index_indicator_scale_translations_on_name"

  create_table "indicator_scales", :force => true do |t|
    t.integer  "indicator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color"
  end

  add_index "indicator_scales", ["indicator_id"], :name => "index_indicator_scales_on_indicator_id"

  create_table "indicator_translations", :force => true do |t|
    t.integer  "indicator_id"
    t.string   "locale"
    t.string   "name"
    t.string   "name_abbrv"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  add_index "indicator_translations", ["indicator_id"], :name => "index_indicator_translations_on_indicator_id"
  add_index "indicator_translations", ["locale"], :name => "index_indicator_translations_on_locale"
  add_index "indicator_translations", ["name"], :name => "index_indicator_translations_on_name"

  create_table "indicators", :force => true do |t|
    t.integer  "event_id"
    t.integer  "shape_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "number_format"
  end

  add_index "indicators", ["event_id"], :name => "index_indicators_on_event_id"
  add_index "indicators", ["shape_type_id"], :name => "index_indicators_on_shape_type_id"

  create_table "locales", :force => true do |t|
    t.string   "language"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_translations", :force => true do |t|
    t.integer  "page_id"
    t.string   "locale"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  add_index "page_translations", ["locale"], :name => "index_page_translations_on_locale"
  add_index "page_translations", ["page_id"], :name => "index_page_translations_on_page_id"

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["name"], :name => "index_pages_on_name"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shape_translations", :force => true do |t|
    t.integer  "shape_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shape_translations", ["locale"], :name => "index_shape_translations_on_locale"
  add_index "shape_translations", ["name"], :name => "index_shape_translations_on_name"
  add_index "shape_translations", ["shape_id"], :name => "index_shape_translations_on_shape_id"

  create_table "shape_type_translations", :force => true do |t|
    t.integer  "shape_type_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shape_type_translations", ["locale"], :name => "index_shape_type_translations_on_locale"
  add_index "shape_type_translations", ["name"], :name => "index_shape_type_translations_on_name"
  add_index "shape_type_translations", ["shape_type_id"], :name => "index_shape_type_translations_on_shape_type_id"

  create_table "shape_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
  end

  add_index "shape_types", ["ancestry"], :name => "index_shape_types_on_ancestry"

  create_table "shapes", :force => true do |t|
    t.integer  "shape_type_id"
    t.string   "common_id"
    t.text     "geometry",      :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.string   "common_name"
  end

  add_index "shapes", ["ancestry"], :name => "index_shapes_on_ancestry"
  add_index "shapes", ["common_id"], :name => "index_shapes_on_common_id"
  add_index "shapes", ["common_name"], :name => "index_shapes_on_common_name"
  add_index "shapes", ["shape_type_id"], :name => "index_shapes_on_shape_type_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "confirmed_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
