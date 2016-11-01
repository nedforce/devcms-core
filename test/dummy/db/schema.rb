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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161101122926) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string   "login",                     :limit=>255, :null=>false, :index=>{:name=>"index_users_on_login", :unique=>true}
    t.string   "email_address",             :limit=>255, :null=>false, :index=>{:name=>"index_users_on_email_address", :unique=>true}
    t.string   "password_hash",             :limit=>255, :null=>false
    t.string   "password_salt",             :limit=>255, :null=>false
    t.datetime "created_at",                :index=>{:name=>"index_users_on_created_at"}
    t.datetime "updated_at",                :index=>{:name=>"index_users_on_updated_at"}
    t.boolean  "verified",                  :default=>false, :null=>false, :index=>{:name=>"index_users_on_verified"}
    t.string   "verification_code",         :limit=>255, :default=>"-", :null=>false
    t.string   "first_name",                :limit=>255, :index=>{:name=>"index_users_on_first_name"}
    t.string   "surname",                   :limit=>255, :index=>{:name=>"index_users_on_surname"}
    t.string   "sex",                       :limit=>255, :index=>{:name=>"index_users_on_sex"}
    t.string   "type",                      :limit=>255
    t.string   "password_reset_token",      :limit=>255
    t.datetime "password_reset_expiration"
    t.boolean  "blocked",                   :default=>false
    t.integer  "failed_logins",             :default=>0
    t.string   "auth_token",                :limit=>255, :index=>{:name=>"index_users_on_auth_token"}
    t.datetime "renewed_password_at"
  end

  create_table "nodes", force: :cascade do |t|
    t.string   "content_type",                   :limit=>255, :null=>false, :index=>{:name=>"index_nodes_on_content_type_and_content_id", :with=>["content_id"], :unique=>true}
    t.integer  "content_id",                     :null=>false
    t.datetime "created_at",                     :index=>{:name=>"index_nodes_on_created_at"}
    t.datetime "updated_at",                     :index=>{:name=>"index_nodes_on_updated_at"}
    t.boolean  "inherits_side_box_elements",     :default=>true, :null=>false, :index=>{:name=>"index_nodes_on_inherits_side_box_elements"}
    t.boolean  "private",                        :default=>false, :index=>{:name=>"index_nodes_on_hidden"}
    t.string   "url_alias",                      :limit=>255, :index=>{:name=>"index_nodes_on_url_alias"}
    t.boolean  "show_in_menu",                   :default=>false, :null=>false, :index=>{:name=>"index_nodes_on_show_in_menu"}
    t.boolean  "commentable",                    :default=>false
    t.boolean  "has_changed_feed",               :default=>false
    t.integer  "hits",                           :default=>0, :null=>false, :index=>{:name=>"index_nodes_on_hits"}
    t.datetime "publication_start_date",         :index=>{:name=>"index_nodes_on_publication_start_date"}
    t.datetime "publication_end_date",           :index=>{:name=>"index_nodes_on_publication_end_date"}
    t.string   "content_box_title",              :limit=>255
    t.string   "content_box_icon",               :limit=>255
    t.string   "content_box_colour",             :limit=>255
    t.integer  "content_box_number_of_items"
    t.string   "ancestry",                       :limit=>255, :index=>{:name=>"index_nodes_on_ancestry"}
    t.integer  "position",                       :index=>{:name=>"index_nodes_on_position"}
    t.string   "layout",                         :limit=>255
    t.string   "layout_variant",                 :limit=>255
    t.text     "layout_configuration"
    t.integer  "responsible_user_id",            :foreign_key=>{:references=>"users", :name=>"nodes_responsible_user_id_fkey", :on_update=>:restrict, :on_delete=>:nullify}
    t.date     "expires_on"
    t.string   "custom_url_suffix",              :limit=>255
    t.string   "custom_url_alias",               :limit=>255, :index=>{:name=>"index_nodes_on_custom_url_alias"}
    t.boolean  "publishable",                    :default=>false, :null=>false, :index=>{:name=>"index_nodes_on_publishable"}
    t.boolean  "hidden",                         :default=>false, :null=>false
    t.string   "sub_content_type",               :limit=>255, :null=>false, :index=>{:name=>"index_nodes_on_sub_content_type"}
    t.integer  "ancestry_depth",                 :default=>0, :index=>{:name=>"index_nodes_on_ancestry_depth"}
    t.string   "title",                          :limit=>255, :index=>{:name=>"index_nodes_on_title"}
    t.string   "expiration_notification_method", :limit=>255, :default=>"inherit"
    t.string   "expiration_email_recipient",     :limit=>255
    t.datetime "deleted_at",                     :index=>{:name=>"index_nodes_on_deleted_at"}
    t.integer  "created_by_id",                  :foreign_key=>{:references=>"users", :name=>"nodes_created_by_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
    t.integer  "updated_by_id",                  :foreign_key=>{:references=>"users", :name=>"nodes_updated_by_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
    t.string   "short_title",                    :limit=>255
    t.string   "locale",                         :limit=>255
    t.datetime "last_checked_at"
    t.string   "content_box_url",                :limit=>255
    t.boolean  "content_box_show_link",          :default=>true
  end
  add_index "nodes", ["private"], :name=>"index_nodes_on_private"

  create_table "abbreviations", force: :cascade do |t|
    t.string   "abbr",       :limit=>255, :null=>false
    t.string   "definition", :limit=>255, :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "node_id",    :foreign_key=>{:references=>"nodes", :name=>"abbreviations_node_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
  end

  create_table "agenda_item_categories", force: :cascade do |t|
    t.string   "name",       :limit=>255, :index=>{:name=>"index_agenda_item_categories_on_name", :unique=>true}
    t.datetime "created_at", :index=>{:name=>"index_agenda_item_categories_on_created_at"}
    t.datetime "updated_at", :index=>{:name=>"index_agenda_item_categories_on_updated_at"}
  end

  create_table "agenda_items", force: :cascade do |t|
    t.integer  "agenda_item_category_id", :index=>{:name=>"index_agenda_items_on_agenda_item_category_id"}, :foreign_key=>{:references=>"agenda_item_categories", :name=>"agenda_items_agenda_item_category_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.string   "description",             :limit=>255, :null=>false
    t.text     "body"
    t.datetime "created_at",              :index=>{:name=>"index_agenda_items_on_created_at"}
    t.datetime "updated_at",              :index=>{:name=>"index_agenda_items_on_updated_at"}
    t.string   "duration",                :limit=>255
    t.string   "chairman",                :limit=>255
    t.string   "notary",                  :limit=>255
    t.string   "staff_member",            :limit=>255
    t.integer  "speaking_rights"
    t.datetime "deleted_at",              :index=>{:name=>"index_agenda_items_on_deleted_at"}
  end

  create_table "alphabetic_indices", force: :cascade do |t|
    t.string   "title",        :limit=>255, :null=>false
    t.datetime "created_at",   :null=>false
    t.datetime "updated_at",   :null=>false
    t.string   "content_type", :limit=>255, :default=>"Page"
    t.datetime "deleted_at",   :index=>{:name=>"index_alphabetic_indices_on_deleted_at"}
  end

  create_table "attachments", force: :cascade do |t|
    t.string   "title",        :limit=>255, :null=>false
    t.integer  "size",         :null=>false
    t.string   "content_type", :limit=>255, :null=>false
    t.string   "filename",     :limit=>255, :null=>false
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id",    :index=>{:name=>"index_attachments_on_parent_id"}, :foreign_key=>{:references=>"attachments", :name=>"attachments_parent_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.string   "thumbnail",    :limit=>255
    t.datetime "created_at",   :index=>{:name=>"index_attachments_on_created_at"}
    t.datetime "updated_at",   :index=>{:name=>"index_attachments_on_updated_at"}
    t.datetime "deleted_at",   :index=>{:name=>"index_attachments_on_deleted_at"}
    t.string   "file",         :limit=>255
  end

  create_table "calendars", force: :cascade do |t|
    t.string   "title",       :limit=>255, :null=>false
    t.text     "description"
    t.datetime "created_at",  :index=>{:name=>"index_calendars_on_created_at"}
    t.datetime "updated_at",  :index=>{:name=>"index_calendars_on_updated_at"}
    t.datetime "deleted_at",  :index=>{:name=>"index_calendars_on_deleted_at"}
  end

  create_table "carrousels", force: :cascade do |t|
    t.string   "title",                     :limit=>255, :null=>false
    t.datetime "created_at",                :null=>false
    t.datetime "updated_at",                :null=>false
    t.integer  "display_time"
    t.integer  "current_carrousel_item_id"  # foreign key references "carrousel_items" (below)
    t.datetime "last_cycled"
    t.integer  "animation"
    t.datetime "deleted_at",                :index=>{:name=>"index_carrousels_on_deleted_at"}
    t.integer  "transition_time"
  end

  create_table "carrousel_items", force: :cascade do |t|
    t.text     "excerpt"
    t.integer  "carrousel_id", :null=>false, :index=>{:name=>"index_carrousel_items_on_carrousel_id"}, :foreign_key=>{:references=>"carrousels", :name=>"carrousel_items_carrousel_id_fkey", :on_update=>:restrict, :on_delete=>:cascade}
    t.string   "item_type",    :limit=>255, :null=>false, :index=>{:name=>"index_carrousel_items_on_item_type_and_item_id", :with=>["item_id"]}
    t.integer  "item_id",      :null=>false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_foreign_key "carrousels", "carrousel_items", :column=>"current_carrousel_item_id", :name=>"carrousels_current_carrousel_item_id_fkey", :on_update=>:restrict, :on_delete=>:restrict

  create_table "categories", force: :cascade do |t|
    t.string   "name",       :limit=>255, :null=>false
    t.integer  "parent_id",  :foreign_key=>{:references=>"categories", :name=>"categories_parent_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "synonyms"
  end

  create_table "combined_calendars", force: :cascade do |t|
    t.string   "title",       :limit=>255, :null=>false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at",  :index=>{:name=>"index_combined_calendars_on_deleted_at"}
  end

  create_table "combined_calendar_nodes", force: :cascade do |t|
    t.integer "combined_calendar_id", :index=>{:name=>"index_combined_calendar_nodes_on_combined_calendar_id"}, :foreign_key=>{:references=>"combined_calendars", :name=>"combined_calendar_nodes_combined_calendar_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
    t.integer "node_id",              :index=>{:name=>"index_combined_calendar_nodes_on_node_id"}, :foreign_key=>{:references=>"nodes", :name=>"combined_calendar_nodes_node_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
  end

  create_table "comments", force: :cascade do |t|
    t.string   "title",            :limit=>50, :default=>""
    t.integer  "commentable_id",   :default=>0, :null=>false
    t.string   "commentable_type", :limit=>15, :default=>"", :null=>false, :index=>{:name=>"index_comments_on_commentable_type_and_commentable_id", :with=>["commentable_id"]}
    t.integer  "user_id",          :default=>0, :index=>{:name=>"index_comments_on_user_id"}
    t.datetime "created_at",       :index=>{:name=>"index_comments_on_created_at"}
    t.datetime "updated_at",       :index=>{:name=>"index_comments_on_updated_at"}
    t.text     "comment",          :default=>""
    t.string   "user_name",        :limit=>255, :default=>"", :null=>false, :index=>{:name=>"index_comments_on_user_name"}
  end

  create_table "contact_boxes", force: :cascade do |t|
    t.string   "title",                    :limit=>255, :null=>false
    t.text     "contact_information",      :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "default_text"
    t.text     "monday_text"
    t.text     "tuesday_text"
    t.text     "wednesday_text"
    t.text     "thursday_text"
    t.text     "friday_text"
    t.text     "saturday_text"
    t.text     "sunday_text"
    t.datetime "deleted_at",               :index=>{:name=>"index_contact_boxes_on_deleted_at"}
    t.boolean  "show_more_addresses_link", :default=>true
    t.boolean  "show_more_times_link",     :default=>true
    t.string   "more_addresses_url",       :limit=>255
    t.string   "more_times_url",           :limit=>255
  end

  create_table "contact_forms", force: :cascade do |t|
    t.string   "title",                             :limit=>255, :null=>false
    t.string   "email_address",                     :limit=>255, :null=>false
    t.text     "description_before_contact_fields"
    t.text     "description_after_contact_fields"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "send_method"
    t.datetime "deleted_at",                        :index=>{:name=>"index_contact_forms_on_deleted_at"}
  end

  create_table "contact_form_fields", force: :cascade do |t|
    t.string   "label",           :limit=>255, :null=>false
    t.string   "field_type",      :limit=>255, :null=>false
    t.integer  "position",        :null=>false
    t.boolean  "obligatory",      :default=>false
    t.text     "default_value"
    t.integer  "contact_form_id", :null=>false, :index=>{:name=>"index_contact_form_fields_on_contact_form_id_and_position", :with=>["position"], :unique=>true}, :foreign_key=>{:references=>"contact_forms", :name=>"contact_form_fields_contact_form_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "content_copies", force: :cascade do |t|
    t.integer  "copied_node_id", :index=>{:name=>"index_content_copies_on_copied_node_id"}, :foreign_key=>{:references=>"nodes", :name=>"content_copies_copied_node_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.datetime "created_at",     :index=>{:name=>"index_content_copies_on_created_at"}
    t.datetime "updated_at",     :index=>{:name=>"index_content_copies_on_updated_at"}
    t.datetime "deleted_at",     :index=>{:name=>"index_content_copies_on_deleted_at"}
  end

  create_table "content_representations", force: :cascade do |t|
    t.integer  "parent_id",   :null=>false, :index=>{:name=>"index_content_representations_on_parent_id_and_content_id", :with=>["content_id"], :unique=>true}, :foreign_key=>{:references=>"nodes", :name=>"content_representations_parent_id_fkey", :on_update=>:restrict, :on_delete=>:cascade}
    t.integer  "content_id",  :foreign_key=>{:references=>"nodes", :name=>"content_representations_content_id_fkey", :on_update=>:restrict, :on_delete=>:cascade}
    t.string   "target",      :limit=>255
    t.integer  "position"
    t.datetime "created_at",  :null=>false
    t.datetime "updated_at",  :null=>false
    t.string   "custom_type", :limit=>255
  end

  create_table "data_warnings", force: :cascade do |t|
    t.integer  "subject_id",   :index=>{:name=>"index_data_warnings_on_subject_id_and_subject_type", :with=>["subject_type"]}
    t.string   "subject_type", :limit=>255
    t.string   "error_code",   :limit=>255, :index=>{:name=>"index_data_warnings_on_error_code"}
    t.text     "message"
    t.string   "status",       :limit=>255, :index=>{:name=>"index_data_warnings_on_status"}
    t.datetime "created_at",   :null=>false
    t.datetime "updated_at",   :null=>false
  end

  create_table "meeting_categories", force: :cascade do |t|
    t.string   "name",       :limit=>255, :index=>{:name=>"index_meeting_categories_on_name", :unique=>true}
    t.datetime "created_at", :index=>{:name=>"index_meeting_categories_on_created_at"}
    t.datetime "updated_at", :index=>{:name=>"index_meeting_categories_on_updated_at"}
  end

  create_table "events", force: :cascade do |t|
    t.string   "title",                :limit=>255, :null=>false
    t.text     "body"
    t.string   "location_description", :limit=>255
    t.datetime "start_time",           :null=>false, :index=>{:name=>"index_calendar_items_on_start_time"}
    t.datetime "end_time",             :null=>false, :index=>{:name=>"index_calendar_items_on_end_time"}
    t.datetime "created_at",           :index=>{:name=>"index_calendar_items_on_created_at"}
    t.datetime "updated_at",           :index=>{:name=>"index_calendar_items_on_updated_at"}
    t.string   "type",                 :limit=>255
    t.integer  "meeting_category_id",  :index=>{:name=>"index_calendar_items_on_meeting_category_id"}, :foreign_key=>{:references=>"meeting_categories", :name=>"calendar_items_meeting_category_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.integer  "repeat_identifier"
    t.text     "dynamic_attributes"
    t.datetime "deleted_at",           :index=>{:name=>"index_events_on_deleted_at"}
    t.boolean  "subscription_enabled", :default=>false
  end

  create_table "event_registrations", force: :cascade do |t|
    t.integer  "event_id",     :foreign_key=>{:references=>"events", :name=>"event_registrations_event_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
    t.integer  "user_id",      :foreign_key=>{:references=>"users", :name=>"event_registrations_user_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
    t.integer  "people_count"
    t.datetime "created_at",   :null=>false
    t.datetime "updated_at",   :null=>false
  end

  create_table "faq_archives", force: :cascade do |t|
    t.string   "title",       :limit=>255, :null=>false
    t.text     "description"
    t.datetime "deleted_at"
    t.datetime "created_at",  :null=>false
    t.datetime "updated_at",  :null=>false
  end

  create_table "faqs", force: :cascade do |t|
    t.string   "title",      :limit=>255, :null=>false
    t.text     "answer"
    t.integer  "hits"
    t.datetime "deleted_at"
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "feeds", force: :cascade do |t|
    t.string   "url",                :limit=>255, :null=>false
    t.datetime "created_at",         :index=>{:name=>"index_feeds_on_created_at"}
    t.datetime "updated_at",         :index=>{:name=>"index_feeds_on_updated_at"}
    t.string   "title",              :limit=>255
    t.text     "cached_parsed_feed"
    t.binary   "xml"
    t.datetime "deleted_at",         :index=>{:name=>"index_feeds_on_deleted_at"}
  end

  create_table "forum_topics", force: :cascade do |t|
    t.string   "title",       :limit=>255, :null=>false, :index=>{:name=>"index_forum_topics_on_title", :unique=>true}
    t.text     "description", :null=>false
    t.datetime "created_at",  :index=>{:name=>"index_forum_topics_on_created_at"}
    t.datetime "updated_at",  :index=>{:name=>"index_forum_topics_on_updated_at"}
    t.datetime "deleted_at",  :index=>{:name=>"index_forum_topics_on_deleted_at"}
  end

  create_table "forum_threads", force: :cascade do |t|
    t.string   "title",          :limit=>255, :null=>false
    t.integer  "user_id",        :null=>false, :index=>{:name=>"index_forum_threads_on_user_id"}, :foreign_key=>{:references=>"users", :name=>"forum_threads_user_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.integer  "forum_topic_id", :null=>false, :index=>{:name=>"index_forum_threads_on_forum_topic_id"}, :foreign_key=>{:references=>"forum_topics", :name=>"forum_threads_forum_topic_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.datetime "created_at",     :index=>{:name=>"index_forum_threads_on_created_at"}
    t.datetime "updated_at",     :index=>{:name=>"index_forum_threads_on_updated_at"}
    t.boolean  "closed",         :default=>false, :null=>false
  end

  create_table "forum_posts", force: :cascade do |t|
    t.text     "body",            :null=>false
    t.integer  "forum_thread_id", :null=>false, :index=>{:name=>"index_forum_posts_on_forum_thread_id"}, :foreign_key=>{:references=>"forum_threads", :name=>"forum_posts_forum_thread_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.datetime "created_at",      :index=>{:name=>"index_forum_posts_on_created_at"}
    t.datetime "updated_at",      :index=>{:name=>"index_forum_posts_on_updated_at"}
    t.integer  "user_id",         :index=>{:name=>"index_forum_posts_on_user_id"}
    t.string   "user_name",       :limit=>255, :default=>"", :null=>false, :index=>{:name=>"index_forum_posts_on_user_name"}
  end

  create_table "forums", force: :cascade do |t|
    t.string   "title",       :limit=>255, :null=>false, :index=>{:name=>"index_forums_on_title", :unique=>true}
    t.text     "description", :null=>false
    t.datetime "created_at",  :index=>{:name=>"index_forums_on_created_at"}
    t.datetime "updated_at",  :index=>{:name=>"index_forums_on_updated_at"}
    t.datetime "deleted_at",  :index=>{:name=>"index_forums_on_deleted_at"}
  end

  create_table "html_pages", force: :cascade do |t|
    t.string   "title",      :limit=>255, :null=>false
    t.text     "body",       :null=>false
    t.datetime "created_at", :index=>{:name=>"index_html_pages_on_created_at"}
    t.datetime "updated_at", :index=>{:name=>"index_html_pages_on_updated_at"}
    t.datetime "deleted_at", :index=>{:name=>"index_html_pages_on_deleted_at"}
  end

  create_table "images", force: :cascade do |t|
    t.string   "title",           :limit=>255, :null=>false
    t.datetime "created_at",      :index=>{:name=>"index_images_on_created_at"}
    t.datetime "updated_at",      :index=>{:name=>"index_images_on_updated_at"}
    t.string   "alt",             :limit=>255
    t.text     "description"
    t.string   "url",             :limit=>255
    t.boolean  "is_for_header",   :default=>false
    t.integer  "offset"
    t.boolean  "show_in_listing", :default=>true, :null=>false
    t.datetime "deleted_at",      :index=>{:name=>"index_images_on_deleted_at"}
    t.string   "file",            :limit=>255
  end

  create_table "interests", force: :cascade do |t|
    t.string "title", :limit=>255, :null=>false
  end

  create_table "interests_users", id: false, force: :cascade do |t|
    t.integer "interest_id", :foreign_key=>{:references=>"interests", :name=>"interests_users_interest_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.integer "user_id",     :index=>{:name=>"index_interests_users_on_user_id_and_interest_id", :with=>["interest_id"]}, :foreign_key=>{:references=>"users", :name=>"interests_users_user_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
  end

  create_table "links", force: :cascade do |t|
    t.string   "title",          :limit=>255
    t.string   "description",    :limit=>255
    t.string   "type",           :limit=>255
    t.integer  "linked_node_id", :index=>{:name=>"index_links_on_linked_node_id"}, :foreign_key=>{:references=>"nodes", :name=>"links_linked_node_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.string   "url",            :limit=>255
    t.datetime "created_at",     :index=>{:name=>"index_links_on_created_at"}
    t.datetime "updated_at",     :index=>{:name=>"index_links_on_updated_at"}
    t.datetime "deleted_at",     :index=>{:name=>"index_links_on_deleted_at"}
    t.string   "email_address"
  end

  create_table "links_boxes", force: :cascade do |t|
    t.string   "title",       :limit=>255, :null=>false
    t.text     "description"
    t.datetime "created_at",  :null=>false
    t.datetime "updated_at",  :null=>false
    t.datetime "deleted_at",  :index=>{:name=>"index_links_boxes_on_deleted_at"}
  end

  create_table "login_attempts", force: :cascade do |t|
    t.string   "ip",         :limit=>255, :null=>false
    t.string   "user_login", :limit=>255
    t.boolean  "success",    :default=>false, :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "news_archives", force: :cascade do |t|
    t.string   "title",          :limit=>255, :null=>false
    t.text     "description"
    t.datetime "created_at",     :index=>{:name=>"index_news_archives_on_created_at"}
    t.datetime "updated_at",     :index=>{:name=>"index_news_archives_on_updated_at"}
    t.datetime "deleted_at",     :index=>{:name=>"index_news_archives_on_deleted_at"}
    t.integer  "items_featured"
    t.integer  "items_max"
    t.boolean  "archived",       :default=>false
  end

  create_table "news_items", force: :cascade do |t|
    t.string   "title",            :limit=>255, :null=>false
    t.text     "body",             :null=>false
    t.datetime "created_at",       :index=>{:name=>"index_news_items_on_created_at"}
    t.datetime "updated_at",       :index=>{:name=>"index_news_items_on_updated_at"}
    t.text     "preamble"
    t.datetime "deleted_at",       :index=>{:name=>"index_news_items_on_deleted_at"}
    t.string   "meta_description", :limit=>255
  end

  create_table "news_viewers", force: :cascade do |t|
    t.string   "title",          :limit=>255, :null=>false
    t.text     "description"
    t.datetime "created_at",     :null=>false
    t.datetime "updated_at",     :null=>false
    t.datetime "deleted_at",     :index=>{:name=>"index_news_viewers_on_deleted_at"}
    t.integer  "items_featured"
    t.integer  "items_max"
    t.boolean  "show_archives",  :default=>true
  end

  create_table "news_viewer_archives", force: :cascade do |t|
    t.integer "news_viewer_id",  :index=>{:name=>"index_news_viewer_archives_on_news_viewer_id"}, :foreign_key=>{:references=>"news_viewers", :name=>"news_viewer_archives_news_viewer_id_fkey", :on_update=>:restrict, :on_delete=>:cascade}
    t.integer "news_archive_id", :index=>{:name=>"index_news_viewer_archives_on_news_archive_id"}, :foreign_key=>{:references=>"news_archives", :name=>"news_viewer_archives_news_archive_id_fkey", :on_update=>:restrict, :on_delete=>:cascade}
  end

  create_table "news_viewer_items", force: :cascade do |t|
    t.integer "news_viewer_id", :index=>{:name=>"index_news_viewer_items_on_news_viewer_id"}, :foreign_key=>{:references=>"news_viewers", :name=>"news_viewer_items_news_viewer_id_fkey", :on_update=>:restrict, :on_delete=>:cascade}
    t.integer "news_item_id",   :index=>{:name=>"index_news_viewer_items_on_news_item_id"}, :foreign_key=>{:references=>"news_items", :name=>"news_viewer_items_news_item_id_fkey", :on_update=>:restrict, :on_delete=>:cascade}
    t.integer "position"
  end

  create_table "newsletter_archives", force: :cascade do |t|
    t.string   "title",              :limit=>255, :null=>false
    t.text     "description"
    t.datetime "created_at",         :index=>{:name=>"index_newsletter_archives_on_created_at"}
    t.datetime "updated_at",         :index=>{:name=>"index_newsletter_archives_on_updated_at"}
    t.string   "from_email_address", :limit=>255
    t.datetime "deleted_at",         :index=>{:name=>"index_newsletter_archives_on_deleted_at"}
  end

  create_table "newsletter_archives_users", force: :cascade do |t|
    t.integer  "newsletter_archive_id", :index=>{:name=>"unique_index_on_newsletter_archive_and_user_ids", :with=>["user_id"], :unique=>true}, :foreign_key=>{:references=>"newsletter_archives", :name=>"newsletter_archives_users_newsletter_archive_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.integer  "user_id",               :foreign_key=>{:references=>"users", :name=>"newsletter_archives_users_user_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newsletter_editions", force: :cascade do |t|
    t.string   "title",                :limit=>255, :null=>false
    t.text     "body",                 :null=>false
    t.datetime "created_at",           :index=>{:name=>"index_newsletter_editions_on_created_at"}
    t.datetime "updated_at",           :index=>{:name=>"index_newsletter_editions_on_updated_at"}
    t.string   "published",            :limit=>255, :default=>"unpublished", :index=>{:name=>"index_newsletter_editions_on_published"}
    t.datetime "deleted_at",           :index=>{:name=>"index_newsletter_editions_on_deleted_at"}
    t.integer  "header_image_node_id"
  end

  create_table "newsletter_edition_items", force: :cascade do |t|
    t.integer  "newsletter_edition_id", :null=>false, :index=>{:name=>"index_newsletter_edition_items_on_newsletter_edition_id"}, :foreign_key=>{:references=>"newsletter_editions", :name=>"newsletter_edition_items_newsletter_edition_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.string   "item_type",             :limit=>255, :null=>false, :index=>{:name=>"index_newsletter_edition_items_on_item_type_and_item_id", :with=>["item_id"]}
    t.integer  "item_id",               :null=>false
    t.integer  "position"
    t.datetime "created_at",            :index=>{:name=>"index_newsletter_edition_items_on_created_at"}
    t.datetime "updated_at",            :index=>{:name=>"index_newsletter_edition_items_on_updated_at"}
  end
  add_index "newsletter_edition_items", ["newsletter_edition_id", "position"], :name=>"index_on_edition_items_and_position"

  create_table "newsletter_edition_queues", force: :cascade do |t|
    t.integer  "newsletter_edition_id", :index=>{:name=>"unique_index_on_newsletter_edition_and_user_ids", :with=>["user_id"], :unique=>true}, :foreign_key=>{:references=>"newsletter_editions", :name=>"newsletter_edition_queues_newsletter_edition_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.integer  "user_id",               :foreign_key=>{:references=>"users", :name=>"newsletter_edition_queues_user_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.datetime "created_at",            :index=>{:name=>"index_newsletter_edition_queues_on_created_at"}
    t.datetime "updated_at",            :index=>{:name=>"index_newsletter_edition_queues_on_updated_at"}
  end

  create_table "pages", force: :cascade do |t|
    t.string   "title",            :limit=>255, :null=>false
    t.text     "body",             :null=>false
    t.datetime "created_at",       :index=>{:name=>"index_pages_on_created_at"}
    t.datetime "updated_at",       :index=>{:name=>"index_pages_on_updated_at"}
    t.text     "preamble"
    t.datetime "deleted_at",       :index=>{:name=>"index_pages_on_deleted_at"}
    t.string   "meta_description", :limit=>255
  end

  create_table "poll_questions", force: :cascade do |t|
    t.string   "question",   :limit=>255, :null=>false
    t.boolean  "active",     :default=>false, :index=>{:name=>"index_poll_questions_on_active"}
    t.datetime "created_at", :index=>{:name=>"index_poll_questions_on_created_at"}
    t.datetime "updated_at", :index=>{:name=>"index_poll_questions_on_updated_at"}
    t.datetime "deleted_at", :index=>{:name=>"index_poll_questions_on_deleted_at"}
  end

  create_table "poll_options", force: :cascade do |t|
    t.string   "text",             :limit=>255, :null=>false
    t.integer  "poll_question_id", :null=>false, :index=>{:name=>"index_poll_options_on_poll_question_id"}, :foreign_key=>{:references=>"poll_questions", :name=>"poll_options_poll_question_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.datetime "created_at",       :index=>{:name=>"index_poll_options_on_created_at"}
    t.datetime "updated_at",       :index=>{:name=>"index_poll_options_on_updated_at"}
    t.integer  "number_of_votes",  :default=>0, :null=>false
  end

  create_table "polls", force: :cascade do |t|
    t.string   "title",          :limit=>255, :null=>false
    t.datetime "created_at",     :index=>{:name=>"index_polls_on_created_at"}
    t.datetime "updated_at",     :index=>{:name=>"index_polls_on_updated_at"}
    t.boolean  "requires_login", :default=>false
    t.datetime "deleted_at",     :index=>{:name=>"index_polls_on_deleted_at"}
  end

  create_table "responses", force: :cascade do |t|
    t.integer  "contact_form_id", :foreign_key=>{:references=>"contact_forms", :name=>"responses_contact_form_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
    t.string   "ip",              :limit=>255
    t.datetime "time"
    t.datetime "created_at",      :null=>false
    t.datetime "updated_at",      :null=>false
    t.string   "email",           :limit=>255
  end

  create_table "response_fields", force: :cascade do |t|
    t.integer  "response_id",           :foreign_key=>{:references=>"responses", :name=>"response_fields_response_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
    t.integer  "contact_form_field_id", :foreign_key=>{:references=>"contact_form_fields", :name=>"response_fields_contact_form_field_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
    t.text     "value"
    t.datetime "created_at",            :null=>false
    t.datetime "updated_at",            :null=>false
    t.string   "file",                  :limit=>255
  end

  create_table "role_assignments", force: :cascade do |t|
    t.integer  "user_id",    :index=>{:name=>"index_role_assignments_on_user_id_and_name", :with=>["name"]}, :foreign_key=>{:references=>"users", :name=>"role_assignments_user_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.integer  "node_id",    :index=>{:name=>"index_role_assignments_on_node_id_and_user_id", :with=>["user_id"], :unique=>true}, :foreign_key=>{:references=>"nodes", :name=>"role_assignments_node_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.string   "name",       :limit=>255, :null=>false
    t.datetime "created_at", :index=>{:name=>"index_role_assignments_on_created_at"}
    t.datetime "updated_at", :index=>{:name=>"index_role_assignments_on_updated_at"}
  end

  create_table "search_pages", force: :cascade do |t|
    t.string   "title",      :limit=>255, :null=>false
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
    t.datetime "deleted_at", :index=>{:name=>"index_search_pages_on_deleted_at"}
  end

  create_table "sections", force: :cascade do |t|
    t.string   "title",                    :limit=>255, :null=>false
    t.text     "description"
    t.datetime "created_at",               :index=>{:name=>"index_sections_on_created_at"}
    t.datetime "updated_at",               :index=>{:name=>"index_sections_on_updated_at"}
    t.integer  "frontpage_node_id",        :index=>{:name=>"index_sections_on_frontpage_node_id"}, :foreign_key=>{:references=>"nodes", :name=>"sections_frontpage_node_id_fkey", :on_update=>:no_action, :on_delete=>:nullify}
    t.string   "type",                     :limit=>255
    t.string   "domain",                   :limit=>255, :index=>{:name=>"index_sections_on_domain", :unique=>true}
    t.string   "analytics_code",           :limit=>255
    t.text     "expiration_email_body"
    t.string   "expiration_email_subject", :limit=>255
    t.datetime "deleted_at",               :index=>{:name=>"index_sections_on_deleted_at"}
    t.string   "piwik_site_id",            :limit=>255
    t.string   "meta_description"
  end

  create_table "settings", force: :cascade do |t|
    t.string   "key",        :limit=>255, :null=>false, :index=>{:name=>"index_settings_on_key"}
    t.string   "label",      :limit=>255
    t.text     "value"
    t.boolean  "editable"
    t.boolean  "deletable"
    t.boolean  "deleted"
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
  end

  create_table "social_media_links_boxes", force: :cascade do |t|
    t.string   "title",         :limit=>255, :null=>false
    t.string   "twitter_url",   :limit=>255
    t.string   "facebook_url",  :limit=>255
    t.string   "linkedin_url",  :limit=>255
    t.string   "youtube_url",   :limit=>255
    t.string   "flickr_url",    :limit=>255
    t.datetime "created_at",    :null=>false
    t.datetime "updated_at",    :null=>false
    t.datetime "deleted_at",    :index=>{:name=>"index_social_media_links_boxes_on_deleted_at"}
    t.string   "instagram_url", :limit=>255
  end

  create_table "synonyms", force: :cascade do |t|
    t.string   "original",   :limit=>255, :null=>false, :index=>{:name=>"index_synonyms_on_original_and_name", :with=>["name"], :unique=>true}
    t.string   "name",       :limit=>255, :null=>false
    t.float    "weight",     :default=>0.25, :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "node_id",    :foreign_key=>{:references=>"nodes", :name=>"synonyms_node_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name",           :limit=>255, :index=>{:name=>"index_tags_on_name", :unique=>true}
    t.integer "taggings_count", :default=>0
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        :index=>{:name=>"taggings_idx", :with=>["taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], :unique=>true}, :foreign_key=>{:references=>"tags", :name=>"taggings_tag_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
    t.integer  "taggable_id",   :index=>{:name=>"index_taggings_on_taggable_id_and_taggable_type_and_context", :with=>["taggable_type", "context"]}
    t.integer  "tagger_id"
    t.string   "tagger_type",   :limit=>255
    t.string   "taggable_type", :limit=>255
    t.string   "context",       :limit=>255
    t.datetime "created_at"
  end

  create_table "themes", force: :cascade do |t|
    t.string   "title",      :limit=>255, :null=>false
    t.string   "type",       :limit=>255
    t.datetime "created_at", :null=>false
    t.datetime "updated_at", :null=>false
    t.datetime "deleted_at", :index=>{:name=>"index_themes_on_deleted_at"}
  end

  create_table "top_hits_pages", force: :cascade do |t|
    t.string   "title",       :limit=>255, :null=>false
    t.text     "description"
    t.datetime "created_at",  :index=>{:name=>"index_top_hits_pages_on_created_at"}
    t.datetime "updated_at",  :index=>{:name=>"index_top_hits_pages_on_updated_at"}
    t.datetime "deleted_at",  :index=>{:name=>"index_top_hits_pages_on_deleted_at"}
  end

  create_table "user_categories", force: :cascade do |t|
    t.integer  "user_id",     :null=>false, :index=>{:name=>"index_user_categories_on_user_id_and_category_id", :with=>["category_id"], :unique=>true}, :foreign_key=>{:references=>"users", :name=>"user_categories_user_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
    t.integer  "category_id", :null=>false, :foreign_key=>{:references=>"categories", :name=>"user_categories_category_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
    t.datetime "created_at",  :null=>false
    t.datetime "updated_at",  :null=>false
  end

  create_table "user_poll_question_votes", force: :cascade do |t|
    t.integer  "user_id",          :foreign_key=>{:references=>"users", :name=>"user_poll_question_votes_user_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
    t.integer  "poll_question_id", :foreign_key=>{:references=>"poll_questions", :name=>"user_poll_question_votes_poll_question_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
    t.datetime "created_at",       :null=>false
    t.datetime "updated_at",       :null=>false
  end

  create_table "versions", force: :cascade do |t|
    t.integer  "versionable_id",   :index=>{:name=>"unique_index_on_versionable_type_and_number", :with=>["versionable_type", "number"], :unique=>true}
    t.string   "versionable_type", :limit=>255
    t.integer  "number"
    t.text     "yaml"
    t.datetime "created_at",       :index=>{:name=>"index_versions_on_created_at"}
    t.string   "status",           :limit=>255, :null=>false, :index=>{:name=>"index_versions_on_status"}
    t.integer  "editor_id",        :index=>{:name=>"index_versions_on_editor_id"}, :foreign_key=>{:references=>"users", :name=>"versions_editor_id_fkey", :on_update=>:restrict, :on_delete=>:restrict}
    t.text     "editor_comment"
  end
  add_index "versions", ["versionable_id", "versionable_type"], :name=>"index_on_versionable_type"

  create_table "weblog_archives", force: :cascade do |t|
    t.string   "title",       :limit=>255, :null=>false
    t.text     "description"
    t.datetime "created_at",  :index=>{:name=>"index_weblog_archives_on_created_at"}
    t.datetime "updated_at",  :index=>{:name=>"index_weblog_archives_on_updated_at"}
    t.datetime "deleted_at",  :index=>{:name=>"index_weblog_archives_on_deleted_at"}
  end

  create_table "weblog_posts", force: :cascade do |t|
    t.string   "title",      :limit=>255, :null=>false
    t.text     "body",       :null=>false
    t.text     "preamble"
    t.datetime "created_at", :index=>{:name=>"index_weblog_posts_on_created_at"}
    t.datetime "updated_at", :index=>{:name=>"index_weblog_posts_on_updated_at"}
    t.datetime "deleted_at", :index=>{:name=>"index_weblog_posts_on_deleted_at"}
  end

  create_table "weblogs", force: :cascade do |t|
    t.string   "title",       :limit=>255, :null=>false
    t.text     "description"
    t.integer  "user_id",     :null=>false, :foreign_key=>{:references=>"users", :name=>"weblogs_user_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.datetime "created_at",  :index=>{:name=>"index_weblogs_on_created_at"}
    t.datetime "updated_at",  :index=>{:name=>"index_weblogs_on_updated_at"}
    t.datetime "deleted_at",  :index=>{:name=>"index_weblogs_on_deleted_at"}
  end

end
