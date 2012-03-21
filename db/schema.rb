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

ActiveRecord::Schema.define(:version => 20120321084509) do

  create_table "data", :force => true do |t|
    t.integer  "indicator_id"
    t.string   "common_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_translations", :force => true do |t|
    t.integer  "event_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_translations", ["event_id"], :name => "index_event_translations_on_event_id"
  add_index "event_translations", ["locale"], :name => "index_event_translations_on_locale"

  create_table "event_type_translations", :force => true do |t|
    t.integer  "event_type_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_type_translations", ["event_type_id"], :name => "index_event_type_translations_on_event_type_id"
  add_index "event_type_translations", ["locale"], :name => "index_event_type_translations_on_locale"

  create_table "event_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "event_type_id"
    t.integer  "shape_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "indicator_scales", :force => true do |t|
    t.integer  "indicator_id"
    t.integer  "min"
    t.integer  "max"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "indicator_translations", :force => true do |t|
    t.integer  "indicator_id"
    t.string   "locale"
    t.string   "name"
    t.string   "name_abbrv"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "indicator_translations", ["indicator_id"], :name => "index_indicator_translations_on_indicator_id"
  add_index "indicator_translations", ["locale"], :name => "index_indicator_translations_on_locale"

  create_table "indicators", :force => true do |t|
    t.integer  "event_id"
    t.integer  "shape_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locales", :force => true do |t|
    t.string   "language"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shape_translations", :force => true do |t|
    t.integer  "shape_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shape_translations", ["locale"], :name => "index_shape_translations_on_locale"
  add_index "shape_translations", ["shape_id"], :name => "index_shape_translations_on_shape_id"

  create_table "shape_type_translations", :force => true do |t|
    t.integer  "shape_type_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shape_type_translations", ["locale"], :name => "index_shape_type_translations_on_locale"
  add_index "shape_type_translations", ["shape_type_id"], :name => "index_shape_type_translations_on_shape_type_id"

  create_table "shape_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shapes", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "shape_type_id"
    t.string   "common_id"
    t.text     "geo_data",      :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
