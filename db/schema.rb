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

ActiveRecord::Schema.define(:version => 20120820082416) do

  create_table "core_indicator_translations", :force => true do |t|
    t.integer  "core_indicator_id"
    t.string   "locale"
    t.string   "name"
    t.string   "name_abbrv"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "core_indicator_translations", ["core_indicator_id"], :name => "index_37cd3f397a23bc4814c4326c32270bb21f526af0"
  add_index "core_indicator_translations", ["locale", "name"], :name => "index_core_indicator_translations_on_locale_and_name"
  add_index "core_indicator_translations", ["name_abbrv"], :name => "index_core_indicator_translations_on_name_abbrv"

  create_table "core_indicators", :force => true do |t|
    t.integer  "indicator_type_id"
    t.string   "number_format"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.string   "color"
  end

  add_index "core_indicators", ["ancestry"], :name => "index_core_indicators_on_ancestry"
  add_index "core_indicators", ["indicator_type_id"], :name => "index_core_indicators_on_indicator_type_id"

  create_table "data", :force => true do |t|
    t.integer  "indicator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "value",        :precision => 16, :scale => 4
  end

  add_index "data", ["indicator_id"], :name => "index_data_on_indicator_id"
  add_index "data", ["value"], :name => "index_data_on_value"

  create_table "datum_translations", :force => true do |t|
    t.integer  "datum_id"
    t.string   "locale"
    t.string   "common_id"
    t.string   "common_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "datum_translations", ["datum_id"], :name => "index_datum_translations_on_datum_id"
  add_index "datum_translations", ["locale", "common_id", "common_name"], :name => "index_datum_translations_on_locale_and_common_id_and_common_name"

  create_table "event_custom_view_translations", :force => true do |t|
    t.integer  "event_custom_view_id"
    t.string   "locale"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_custom_view_translations", ["event_custom_view_id"], :name => "index_48b367b2590fc1cdf17fcdd1f7bf83cb36810d32"
  add_index "event_custom_view_translations", ["locale", "note"], :name => "index_event_custom_view_translations_on_locale_and_note"

  create_table "event_custom_views", :force => true do |t|
    t.integer  "event_id"
    t.integer  "shape_type_id"
    t.integer  "descendant_shape_type_id"
    t.boolean  "is_default_view",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_custom_views", ["descendant_shape_type_id"], :name => "index_event_custom_views_on_descendant_shape_type_id"
  add_index "event_custom_views", ["event_id", "shape_type_id"], :name => "index_event_custom_views_on_event_id_and_shape_type_id"

  create_table "event_indicator_relationships", :force => true do |t|
    t.integer  "event_id",                  :null => false
    t.integer  "indicator_type_id"
    t.integer  "core_indicator_id"
    t.integer  "related_indicator_type_id"
    t.integer  "related_core_indicator_id"
    t.integer  "sort_order",                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_indicator_relationships", ["event_id", "core_indicator_id"], :name => "indicator_rltnshps_event_core_ind"
  add_index "event_indicator_relationships", ["event_id", "indicator_type_id"], :name => "indicator_rltnshps_event_ind_type"
  add_index "event_indicator_relationships", ["related_core_indicator_id"], :name => "index_event_indicator_relationships_on_related_core_indicator_id"
  add_index "event_indicator_relationships", ["related_indicator_type_id"], :name => "index_event_indicator_relationships_on_related_indicator_type_id"

  create_table "event_translations", :force => true do |t|
    t.integer  "event_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_abbrv"
    t.text     "description"
  end

  add_index "event_translations", ["event_id"], :name => "index_event_translations_on_event_id"
  add_index "event_translations", ["locale", "name"], :name => "index_event_translations_on_locale_and_name"
  add_index "event_translations", ["name_abbrv"], :name => "index_event_translations_on_name_abbrv"

  create_table "event_type_translations", :force => true do |t|
    t.integer  "event_type_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_type_translations", ["event_type_id"], :name => "index_event_type_translations_on_event_type_id"
  add_index "event_type_translations", ["locale", "name"], :name => "index_event_type_translations_on_locale_and_name"

  create_table "event_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order", :default => 1
  end

  add_index "event_types", ["sort_order"], :name => "index_event_types_on_sort_order"

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
  add_index "indicator_scale_translations", ["locale", "name"], :name => "index_indicator_scale_translations_on_locale_and_name"

  create_table "indicator_scales", :force => true do |t|
    t.integer  "indicator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color"
  end

  add_index "indicator_scales", ["indicator_id"], :name => "index_indicator_scales_on_indicator_id"

  create_table "indicator_translation_olds", :force => true do |t|
    t.integer  "indicator_id"
    t.string   "locale"
    t.string   "name"
    t.string   "name_abbrv"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  add_index "indicator_translation_olds", ["indicator_id"], :name => "index_indicator_translations_on_indicator_id"
  add_index "indicator_translation_olds", ["locale"], :name => "index_indicator_translations_on_locale"
  add_index "indicator_translation_olds", ["name"], :name => "index_indicator_translations_on_name"

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
  add_index "indicator_translations", ["locale", "name"], :name => "index_indicator_translations_on_locale_and_name"

  create_table "indicator_type_translations", :force => true do |t|
    t.integer  "indicator_type_id"
    t.string   "locale"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "summary_name"
  end

  add_index "indicator_type_translations", ["indicator_type_id"], :name => "index_d1368a672c18e8979b1f029497e86e371a15a431"
  add_index "indicator_type_translations", ["locale", "name"], :name => "index_indicator_type_translations_on_locale_and_name"

  create_table "indicator_types", :force => true do |t|
    t.boolean  "has_summary", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order",  :default => 1
  end

  add_index "indicator_types", ["sort_order"], :name => "index_indicator_types_on_sort_order"

  create_table "indicators", :force => true do |t|
    t.integer  "event_id"
    t.integer  "shape_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "core_indicator_id"
  end

  add_index "indicators", ["event_id", "shape_type_id", "core_indicator_id"], :name => "inds_event_shape_type_core_ind"

  create_table "news", :force => true do |t|
    t.string   "news_type"
    t.datetime "date_posted"
    t.string   "data_archive_folder"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "news", ["data_archive_folder"], :name => "index_news_on_data_archive_folder"
  add_index "news", ["date_posted"], :name => "index_news_on_date_posted"
  add_index "news", ["news_type"], :name => "index_news_on_news_type"

  create_table "news_translations", :force => true do |t|
    t.integer  "news_id"
    t.string   "locale"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "news_translations", ["locale"], :name => "index_news_translations_on_locale"
  add_index "news_translations", ["news_id"], :name => "index_news_translations_on_news_id"

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

  create_table "regions_districts", :id => false, :force => true do |t|
    t.string  "region"
    t.integer "district_id"
    t.string  "district_name"
    t.integer "precinct_id"
    t.string  "precinct_name"
  end

  add_index "regions_districts", ["district_id", "precinct_id"], :name => "district_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shape_names", :primary_key => "en", :force => true do |t|
    t.string "ka", :null => false
  end

  create_table "shape_translations", :force => true do |t|
    t.integer  "shape_id"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "common_id"
    t.string   "common_name"
  end

  add_index "shape_translations", ["locale", "common_id", "common_name"], :name => "index_shape_translations_on_locale_and_common_id_and_common_name"
  add_index "shape_translations", ["shape_id"], :name => "index_shape_translations_on_shape_id"

  create_table "shape_type_translations", :force => true do |t|
    t.integer  "shape_type_id"
    t.string   "locale"
    t.string   "name_singular"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_plural"
  end

  add_index "shape_type_translations", ["locale", "name_singular"], :name => "index_shape_type_translations_on_locale_and_name_singular"
  add_index "shape_type_translations", ["name_plural"], :name => "index_shape_type_translations_on_name_plural"
  add_index "shape_type_translations", ["shape_type_id"], :name => "index_shape_type_translations_on_shape_type_id"

  create_table "shape_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
  end

  add_index "shape_types", ["ancestry"], :name => "index_shape_types_on_ancestry"

  create_table "shapes", :force => true do |t|
    t.integer  "shape_type_id"
    t.text     "geometry",      :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
  end

  add_index "shapes", ["ancestry"], :name => "index_shapes_on_ancestry"
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
