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

ActiveRecord::Schema.define(:version => 20120208013513) do

  create_table "addresses", :force => true do |t|
    t.string   "label"
    t.string   "line1"
    t.string   "line2"
    t.string   "city"
    t.integer  "zipcode"
    t.string   "state"
    t.string   "country"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.text     "geo_location_object"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["owner_id"], :name => "index_addresses_on_owner_id"
  add_index "addresses", ["owner_type"], :name => "index_addresses_on_owner_type"

  create_table "assets", :force => true do |t|
    t.string   "name"
    t.string   "source_url"
    t.string   "url"
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.integer  "asset_file_size"
    t.datetime "asset_updated_at"
    t.string   "attachable_type"
    t.integer  "attachable_id"
    t.integer  "ipaper_id"
    t.string   "ipaper_access_key"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assets", ["attachable_id", "attachable_type"], :name => "index_assets_on_attachable_id_and_attachable_type"
  add_index "assets", ["user_id"], :name => "index_assets_on_user_id"

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "provider_name"
    t.string   "provider_username"
    t.text     "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["provider"], :name => "index_authentications_on_provider"
  add_index "authentications", ["token"], :name => "index_authentications_on_token", :unique => true
  add_index "authentications", ["uid"], :name => "index_authentications_on_uid"
  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "certificates", :force => true do |t|
    t.integer  "user_id"
    t.integer  "offer_id"
    t.text     "offer_snapshot"
    t.integer  "business_id"
    t.integer  "school_id"
    t.integer  "transaction_id"
    t.float    "cost"
    t.float    "value"
    t.float    "donation"
    t.float    "fee"
    t.text     "note"
    t.text     "extra_info"
    t.datetime "purchased_on"
    t.datetime "expires_on"
    t.boolean  "is_used"
    t.datetime "used_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "certificates", ["business_id"], :name => "index_certificates_on_business_id"
  add_index "certificates", ["is_used"], :name => "index_certificates_on_is_used"
  add_index "certificates", ["offer_id"], :name => "index_certificates_on_offer_id"
  add_index "certificates", ["school_id"], :name => "index_certificates_on_school_id"
  add_index "certificates", ["used_on"], :name => "index_certificates_on_used_on"
  add_index "certificates", ["user_id"], :name => "index_certificates_on_user_id"

  create_table "circles", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "owner_id"
    t.integer  "source_id"
    t.string   "source_type"
    t.string   "random_name"
    t.string   "settings"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pin"
  end

  add_index "circles", ["owner_id"], :name => "index_circles_on_owner_id"
  add_index "circles", ["random_name"], :name => "index_circles_on_random_name", :unique => true
  add_index "circles", ["source_id"], :name => "index_circles_on_source_id"
  add_index "circles", ["source_type"], :name => "index_circles_on_source_type"

  create_table "classrooms", :force => true do |t|
    t.string   "name"
    t.string   "teacher"
    t.string   "grade_level"
    t.string   "school_name"
    t.integer  "school_id"
    t.text     "about"
    t.integer  "user_id"
    t.string   "random_code"
    t.string   "school_year"
    t.string   "school_association_status", :default => "unverified"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "classrooms", ["name"], :name => "index_classrooms_on_name"
  add_index "classrooms", ["random_code"], :name => "index_classrooms_on_random_code", :unique => true
  add_index "classrooms", ["school_id"], :name => "index_classrooms_on_school_id"
  add_index "classrooms", ["user_id"], :name => "index_classrooms_on_user_id"

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "families", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.text     "languages"
    t.text     "about"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "families", ["user_id"], :name => "index_families_on_user_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "about"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["name"], :name => "index_groups_on_name"
  add_index "groups", ["user_id"], :name => "index_groups_on_user_id"

  create_table "interested_people", :force => true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "inviter_id"
    t.string   "email"
    t.integer  "circle_id"
    t.text     "registration_info"
    t.datetime "sent_on"
    t.datetime "expires_on"
    t.integer  "times_sent",                      :default => 0
    t.string   "token",             :limit => 60
    t.boolean  "is_used",                         :default => false
    t.text     "optional_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["circle_id"], :name => "index_invitations_on_circle_id"
  add_index "invitations", ["email"], :name => "index_invitations_on_email"
  add_index "invitations", ["expires_on"], :name => "index_invitations_on_expires_on"
  add_index "invitations", ["token"], :name => "index_invitations_on_token", :unique => true

  create_table "library_items", :force => true do |t|
    t.string   "type"
    t.string   "title"
    t.text     "note"
    t.integer  "circle_id"
    t.integer  "file_id"
    t.string   "source_type"
    t.integer  "source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "library_items", ["circle_id"], :name => "index_library_items_on_circle_id"
  add_index "library_items", ["type"], :name => "index_library_items_on_type"

  create_table "locations", :force => true do |t|
    t.string   "input_string"
    t.text     "geo_object"
    t.integer  "locationable_id"
    t.string   "locationable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "circle_id"
    t.integer  "circle_source_id"
    t.string   "circle_source_type"
    t.text     "roles"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "privacy_settings",   :default => "--- {}\n"
  end

  add_index "memberships", ["circle_id"], :name => "index_memberships_on_circle_id"
  add_index "memberships", ["user_id"], :name => "index_memberships_on_user_id"

  create_table "offers", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.float    "value"
    t.float    "cost"
    t.datetime "start_on"
    t.datetime "end_on"
    t.integer  "max_available"
    t.integer  "business_id"
    t.integer  "campaign_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "offers", ["business_id"], :name => "index_offers_on_business_id"
  add_index "offers", ["campaign_id"], :name => "index_offers_on_campaign_id"

  create_table "phone_numbers", :force => true do |t|
    t.string   "name"
    t.string   "number"
    t.string   "extension"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phone_numbers", ["owner_id"], :name => "index_phone_numbers_on_owner_id"
  add_index "phone_numbers", ["owner_type"], :name => "index_phone_numbers_on_owner_type"

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.string   "content_type"
    t.text     "options"
    t.string   "type"
    t.integer  "receiver_id"
    t.integer  "sender_id"
    t.integer  "circle_id"
    t.text     "data_bag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "thread_id"
    t.datetime "posted_at"
  end

  add_index "posts", ["circle_id"], :name => "index_posts_on_circle_id"
  add_index "posts", ["parent_id"], :name => "index_posts_on_parent_id"
  add_index "posts", ["receiver_id"], :name => "index_posts_on_receiver_id"
  add_index "posts", ["sender_id"], :name => "index_posts_on_sender_id"
  add_index "posts", ["thread_id"], :name => "index_posts_on_thread_id"
  add_index "posts", ["type"], :name => "index_posts_on_type"

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.datetime "when_confirmed"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "birthday"
    t.string   "sex"
    t.string   "time_zone"
    t.string   "locale"
    t.string   "main_role"
    t.text     "about"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "contacts"
  end

  add_index "profiles", ["first_name"], :name => "index_profiles_on_first_name"
  add_index "profiles", ["last_name"], :name => "index_profiles_on_last_name"
  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.string   "category"
    t.string   "grade_range"
    t.string   "description"
    t.string   "pta_url"
    t.string   "web_site_url"
    t.string   "principal"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "photo_s3_url"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "authentication_token"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",                     :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chompon_uid"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "votes", :force => true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type"], :name => "index_votes_on_votable_id_and_votable_type"
  add_index "votes", ["voter_id", "voter_type"], :name => "index_votes_on_voter_id_and_voter_type"

  create_table "zfiles", :force => true do |t|
    t.string   "name"
    t.string   "source_url"
    t.string   "url"
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.integer  "asset_file_size"
    t.datetime "asset_updated_at"
    t.string   "attachable_type"
    t.integer  "attachable_id"
    t.integer  "ipaper_id"
    t.string   "ipaper_access_key"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "zfiles", ["attachable_id", "attachable_type"], :name => "index_zfiles_on_attachable_id_and_attachable_type"
  add_index "zfiles", ["user_id"], :name => "index_zfiles_on_user_id"

end
