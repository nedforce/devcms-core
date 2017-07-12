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

ActiveRecord::Schema.define(version: 20170126154800) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string   "login",                     :null=>false, :index=>{:name=>"index_users_on_login", :unique=>true}
    t.string   "email_address",             :null=>false, :index=>{:name=>"index_users_on_email_address", :unique=>true}
    t.string   "password_hash",             :null=>false
    t.string   "password_salt",             :null=>false
    t.datetime "created_at",                :index=>{:name=>"index_users_on_created_at"}
    t.datetime "updated_at",                :index=>{:name=>"index_users_on_updated_at"}
    t.boolean  "verified",                  :default=>false, :null=>false, :index=>{:name=>"index_users_on_verified"}
    t.string   "verification_code",         :default=>"-", :null=>false
    t.string   "first_name",                :index=>{:name=>"index_users_on_first_name"}
    t.string   "surname",                   :index=>{:name=>"index_users_on_surname"}
    t.string   "sex",                       :index=>{:name=>"index_users_on_sex"}
    t.string   "type"
    t.string   "password_reset_token"
    t.datetime "password_reset_expiration"
    t.boolean  "blocked",                   :default=>false
    t.integer  "failed_logins",             :default=>0
    t.string   "auth_token",                :index=>{:name=>"index_users_on_auth_token"}
    t.datetime "renewed_password_at"
  end

  create_table "nodes", force: :cascade do |t|
    t.string   "content_type",                   :null=>false, :index=>{:name=>"index_nodes_on_content_type_and_content_id", :with=>["content_id"], :unique=>true}
    t.integer  "content_id",                     :null=>false
    t.datetime "created_at",                     :index=>{:name=>"index_nodes_on_created_at"}
    t.datetime "updated_at",                     :index=>{:name=>"index_nodes_on_updated_at"}
    t.boolean  "inherits_side_box_elements",     :default=>true, :null=>false, :index=>{:name=>"index_nodes_on_inherits_side_box_elements"}
    t.boolean  "private",                        :default=>false, :index=>{:name=>"index_nodes_on_private"}
    t.string   "url_alias",                      :index=>{:name=>"index_nodes_on_url_alias"}
    t.boolean  "show_in_menu",                   :default=>false, :null=>false, :index=>{:name=>"index_nodes_on_show_in_menu"}
    t.boolean  "commentable",                    :default=>false
    t.boolean  "has_changed_feed",               :default=>false
    t.integer  "hits",                           :default=>0, :null=>false, :index=>{:name=>"index_nodes_on_hits"}
    t.datetime "publication_start_date",         :index=>{:name=>"index_nodes_on_publication_start_date"}
    t.datetime "publication_end_date",           :index=>{:name=>"index_nodes_on_publication_end_date"}
    t.string   "content_box_title"
    t.string   "content_box_icon"
    t.string   "content_box_colour"
    t.integer  "content_box_number_of_items"
    t.string   "ancestry",                       :index=>{:name=>"index_nodes_on_ancestry"}
    t.integer  "position",                       :index=>{:name=>"index_nodes_on_position"}
    t.string   "layout"
    t.string   "layout_variant"
    t.text     "layout_configuration"
    t.integer  "responsible_user_id",            :index=>{:name=>"fk__nodes_responsible_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_nodes_responsible_user_id", :on_update=>:no_action, :on_delete=>:nullify}
    t.date     "expires_on"
    t.string   "custom_url_suffix"
    t.string   "custom_url_alias",               :index=>{:name=>"index_nodes_on_custom_url_alias"}
    t.boolean  "publishable",                    :default=>false, :null=>false, :index=>{:name=>"index_nodes_on_publishable"}
    t.boolean  "hidden",                         :default=>false, :null=>false, :index=>{:name=>"index_nodes_on_hidden"}
    t.string   "sub_content_type",               :null=>false, :index=>{:name=>"index_nodes_on_sub_content_type"}
    t.integer  "ancestry_depth",                 :default=>0, :index=>{:name=>"index_nodes_on_ancestry_depth"}
    t.string   "title",                          :index=>{:name=>"index_nodes_on_title"}
    t.string   "expiration_notification_method", :default=>"inherit"
    t.string   "expiration_email_recipient"
    t.datetime "deleted_at",                     :index=>{:name=>"index_nodes_on_deleted_at"}
    t.integer  "created_by_id",                  :index=>{:name=>"fk__nodes_created_by_id"}, :foreign_key=>{:references=>"users", :name=>"fk_nodes_created_by_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "updated_by_id",                  :index=>{:name=>"fk__nodes_updated_by_id"}, :foreign_key=>{:references=>"users", :name=>"fk_nodes_updated_by_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "short_title"
    t.string   "locale"
    t.datetime "last_checked_at"
    t.string   "content_box_url"
    t.boolean  "content_box_show_link",          :default=>true
  end

  create_table "abbreviations", force: :cascade do |t|
    t.string   "abbr",       :null=>false
    t.string   "definition", :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "node_id",    :index=>{:name=>"fk__abbreviations_node_id"}, :foreign_key=>{:references=>"nodes", :name=>"fk_abbreviations_node_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_table "agenda_item_categories", force: :cascade do |t|
    t.string   "name",       :index=>{:name=>"index_agenda_item_categories_on_name", :unique=>true}
    t.datetime "created_at", :index=>{:name=>"index_agenda_item_categories_on_created_at"}
    t.datetime "updated_at", :index=>{:name=>"index_agenda_item_categories_on_updated_at"}
  end

  create_table "agenda_items", force: :cascade do |t|
    t.integer  "agenda_item_category_id", :index=>{:name=>"index_agenda_items_on_agenda_item_category_id"}, :foreign_key=>{:references=>"agenda_item_categories", :name=>"agenda_items_agenda_item_category_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.string   "description",             :null=>false
    t.text     "body"
    t.datetime "created_at",              :index=>{:name=>"index_agenda_items_on_created_at"}
    t.datetime "updated_at",              :index=>{:name=>"index_agenda_items_on_updated_at"}
    t.string   "duration"
    t.string   "chairman"
    t.string   "notary"
    t.string   "staff_member"
    t.integer  "speaking_rights"
    t.datetime "deleted_at",              :index=>{:name=>"index_agenda_items_on_deleted_at"}
  end

  create_table "alphabetic_indices", force: :cascade do |t|
    t.string   "title",        :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type", :default=>"Page"
    t.datetime "deleted_at",   :index=>{:name=>"index_alphabetic_indices_on_deleted_at"}
  end

  create_table "attachments", force: :cascade do |t|
    t.string   "title",        :null=>false
    t.integer  "size",         :null=>false
    t.string   "content_type", :null=>false
    t.string   "filename",     :null=>false
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id",    :index=>{:name=>"index_attachments_on_parent_id"}, :foreign_key=>{:references=>"attachments", :name=>"attachments_parent_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.string   "thumbnail"
    t.datetime "created_at",   :index=>{:name=>"index_attachments_on_created_at"}
    t.datetime "updated_at",   :index=>{:name=>"index_attachments_on_updated_at"}
    t.datetime "deleted_at",   :index=>{:name=>"index_attachments_on_deleted_at"}
    t.string   "file"
  end

  create_table "calendars", force: :cascade do |t|
    t.string   "title",       :null=>false
    t.text     "description"
    t.datetime "created_at",  :index=>{:name=>"index_calendars_on_created_at"}
    t.datetime "updated_at",  :index=>{:name=>"index_calendars_on_updated_at"}
    t.datetime "deleted_at",  :index=>{:name=>"index_calendars_on_deleted_at"}
  end

  create_table "carrousels", force: :cascade do |t|
    t.string   "title",                     :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_time"
    t.integer  "current_carrousel_item_id", :index=>{:name=>"fk__carrousels_current_carrousel_item_id"} # foreign key references "carrousel_items" (below)
    t.datetime "last_cycled"
    t.integer  "animation"
    t.datetime "deleted_at",                :index=>{:name=>"index_carrousels_on_deleted_at"}
    t.integer  "transition_time"
  end

  create_table "carrousel_items", force: :cascade do |t|
    t.text     "excerpt"
    t.integer  "carrousel_id", :null=>false, :index=>{:name=>"fk__carrousel_items_carrousel_id"}, :foreign_key=>{:references=>"carrousels", :name=>"fk_carrousel_items_carrousel_id", :on_update=>:no_action, :on_delete=>:cascade}
    t.string   "item_type",    :null=>false, :index=>{:name=>"index_carrousel_items_on_item_type_and_item_id", :with=>["item_id"]}
    t.integer  "item_id",      :null=>false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "carrousel_items", ["carrousel_id"], :name=>"index_carrousel_items_on_carrousel_id"
  add_foreign_key "carrousels", "carrousel_items", :column=>"current_carrousel_item_id", :name=>"fk_carrousels_current_carrousel_item_id", :on_update=>:no_action, :on_delete=>:no_action

  create_table "combined_calendars", force: :cascade do |t|
    t.string   "title",       :null=>false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at",  :index=>{:name=>"index_combined_calendars_on_deleted_at"}
  end

  create_table "combined_calendar_nodes", force: :cascade do |t|
    t.integer "combined_calendar_id", :index=>{:name=>"fk__combined_calendar_nodes_combined_calendar_id"}, :foreign_key=>{:references=>"combined_calendars", :name=>"fk_combined_calendar_nodes_combined_calendar_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer "node_id",              :index=>{:name=>"fk__combined_calendar_nodes_node_id"}, :foreign_key=>{:references=>"nodes", :name=>"fk_combined_calendar_nodes_node_id", :on_update=>:no_action, :on_delete=>:no_action}
  end
  add_index "combined_calendar_nodes", ["combined_calendar_id"], :name=>"index_combined_calendar_nodes_on_combined_calendar_id"
  add_index "combined_calendar_nodes", ["node_id"], :name=>"index_combined_calendar_nodes_on_node_id"

  create_table "comments", force: :cascade do |t|
    t.string   "title",            :limit=>50, :default=>""
    t.integer  "commentable_id",   :default=>0, :null=>false
    t.string   "commentable_type", :limit=>15, :default=>"", :null=>false, :index=>{:name=>"index_comments_on_commentable_type_and_commentable_id", :with=>["commentable_id"]}
    t.integer  "user_id",          :default=>0, :index=>{:name=>"index_comments_on_user_id"}
    t.datetime "created_at",       :index=>{:name=>"index_comments_on_created_at"}
    t.datetime "updated_at",       :index=>{:name=>"index_comments_on_updated_at"}
    t.text     "comment",          :default=>""
    t.string   "user_name",        :default=>"", :null=>false, :index=>{:name=>"index_comments_on_user_name"}
  end

  create_table "contact_boxes", force: :cascade do |t|
    t.string   "title",                    :null=>false
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
    t.string   "more_addresses_url"
    t.string   "more_times_url"
  end

  create_table "contact_forms", force: :cascade do |t|
    t.string   "title",                             :null=>false
    t.string   "email_address",                     :null=>false
    t.text     "description_before_contact_fields"
    t.text     "description_after_contact_fields"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "send_method"
    t.datetime "deleted_at",                        :index=>{:name=>"index_contact_forms_on_deleted_at"}
  end

  create_table "contact_form_fields", force: :cascade do |t|
    t.string   "label",           :null=>false
    t.string   "field_type",      :null=>false
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
    t.integer  "parent_id",   :null=>false, :index=>{:name=>"fk__content_representations_parent_id"}, :foreign_key=>{:references=>"nodes", :name=>"fk_content_representations_parent_id", :on_update=>:no_action, :on_delete=>:cascade}
    t.integer  "content_id",  :index=>{:name=>"fk__content_representations_content_id"}, :foreign_key=>{:references=>"nodes", :name=>"fk_content_representations_content_id", :on_update=>:no_action, :on_delete=>:cascade}
    t.string   "target"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "custom_type"
  end
  add_index "content_representations", ["parent_id", "content_id"], :name=>"index_content_representations_on_parent_id_and_content_id", :unique=>true

  create_table "data_warnings", force: :cascade do |t|
    t.integer  "subject_id",   :index=>{:name=>"index_data_warnings_on_subject_id_and_subject_type", :with=>["subject_type"]}
    t.string   "subject_type"
    t.string   "error_code",   :index=>{:name=>"index_data_warnings_on_error_code"}
    t.text     "message"
    t.string   "status",       :index=>{:name=>"index_data_warnings_on_status"}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "meeting_categories", force: :cascade do |t|
    t.string   "name",       :index=>{:name=>"index_meeting_categories_on_name", :unique=>true}
    t.datetime "created_at", :index=>{:name=>"index_meeting_categories_on_created_at"}
    t.datetime "updated_at", :index=>{:name=>"index_meeting_categories_on_updated_at"}
  end

  create_table "events", force: :cascade do |t|
    t.string   "title",                :null=>false
    t.text     "body"
    t.string   "location_description"
    t.datetime "start_time",           :null=>false, :index=>{:name=>"index_events_on_start_time"}
    t.datetime "end_time",             :null=>false, :index=>{:name=>"index_events_on_end_time"}
    t.datetime "created_at",           :index=>{:name=>"index_events_on_created_at"}
    t.datetime "updated_at",           :index=>{:name=>"index_events_on_updated_at"}
    t.string   "type"
    t.integer  "meeting_category_id",  :index=>{:name=>"index_events_on_meeting_category_id"}, :foreign_key=>{:references=>"meeting_categories", :name=>"events_meeting_category_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.integer  "repeat_identifier"
    t.text     "dynamic_attributes"
    t.datetime "deleted_at",           :index=>{:name=>"index_events_on_deleted_at"}
    t.boolean  "subscription_enabled", :default=>false
  end

  create_table "event_registrations", force: :cascade do |t|
    t.integer  "event_id",     :index=>{:name=>"fk__event_registrations_event_id"}, :foreign_key=>{:references=>"events", :name=>"fk_event_registrations_event_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "user_id",      :index=>{:name=>"fk__event_registrations_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_event_registrations_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "people_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faq_archives", force: :cascade do |t|
    t.string   "title",       :null=>false
    t.text     "description"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faqs", force: :cascade do |t|
    t.string   "title",      :null=>false
    t.text     "answer"
    t.integer  "hits"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feeds", force: :cascade do |t|
    t.string   "url",                :null=>false
    t.datetime "created_at",         :index=>{:name=>"index_feeds_on_created_at"}
    t.datetime "updated_at",         :index=>{:name=>"index_feeds_on_updated_at"}
    t.string   "title"
    t.text     "cached_parsed_feed"
    t.binary   "xml"
    t.datetime "deleted_at",         :index=>{:name=>"index_feeds_on_deleted_at"}
  end

  create_table "forum_topics", force: :cascade do |t|
    t.string   "title",       :null=>false, :index=>{:name=>"index_forum_topics_on_title", :unique=>true}
    t.text     "description", :null=>false
    t.datetime "created_at",  :index=>{:name=>"index_forum_topics_on_created_at"}
    t.datetime "updated_at",  :index=>{:name=>"index_forum_topics_on_updated_at"}
    t.datetime "deleted_at",  :index=>{:name=>"index_forum_topics_on_deleted_at"}
  end

  create_table "forum_threads", force: :cascade do |t|
    t.string   "title",          :null=>false
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
    t.string   "user_name",       :default=>"", :null=>false, :index=>{:name=>"index_forum_posts_on_user_name"}
  end

  create_table "forums", force: :cascade do |t|
    t.string   "title",       :null=>false, :index=>{:name=>"index_forums_on_title", :unique=>true}
    t.text     "description", :null=>false
    t.datetime "created_at",  :index=>{:name=>"index_forums_on_created_at"}
    t.datetime "updated_at",  :index=>{:name=>"index_forums_on_updated_at"}
    t.datetime "deleted_at",  :index=>{:name=>"index_forums_on_deleted_at"}
  end

  create_table "html_pages", force: :cascade do |t|
    t.string   "title",      :null=>false
    t.text     "body",       :null=>false
    t.datetime "created_at", :index=>{:name=>"index_html_pages_on_created_at"}
    t.datetime "updated_at", :index=>{:name=>"index_html_pages_on_updated_at"}
    t.datetime "deleted_at", :index=>{:name=>"index_html_pages_on_deleted_at"}
  end

  create_table "images", force: :cascade do |t|
    t.string   "title",           :null=>false
    t.datetime "created_at",      :index=>{:name=>"index_images_on_created_at"}
    t.datetime "updated_at",      :index=>{:name=>"index_images_on_updated_at"}
    t.string   "alt"
    t.text     "description"
    t.string   "url"
    t.boolean  "is_for_header",   :default=>false
    t.integer  "offset"
    t.boolean  "show_in_listing", :default=>true, :null=>false
    t.datetime "deleted_at",      :index=>{:name=>"index_images_on_deleted_at"}
    t.string   "file"
  end

  create_table "interests", force: :cascade do |t|
    t.string "title", :null=>false
  end

  create_table "interests_users", id: false, force: :cascade do |t|
    t.integer "interest_id", :foreign_key=>{:references=>"interests", :name=>"interests_users_interest_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.integer "user_id",     :index=>{:name=>"index_interests_users_on_user_id_and_interest_id", :with=>["interest_id"]}, :foreign_key=>{:references=>"users", :name=>"interests_users_user_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
  end

  create_table "links", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "type"
    t.integer  "linked_node_id", :index=>{:name=>"index_links_on_linked_node_id"}, :foreign_key=>{:references=>"nodes", :name=>"links_linked_node_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.string   "url"
    t.datetime "created_at",     :index=>{:name=>"index_links_on_created_at"}
    t.datetime "updated_at",     :index=>{:name=>"index_links_on_updated_at"}
    t.datetime "deleted_at",     :index=>{:name=>"index_links_on_deleted_at"}
    t.string   "email_address"
  end

  create_table "links_boxes", force: :cascade do |t|
    t.string   "title",       :null=>false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at",  :index=>{:name=>"index_links_boxes_on_deleted_at"}
  end

  create_table "login_attempts", force: :cascade do |t|
    t.string   "ip",         :null=>false
    t.string   "user_login"
    t.boolean  "success",    :default=>false, :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "news_archives", force: :cascade do |t|
    t.string   "title",          :null=>false
    t.text     "description"
    t.datetime "created_at",     :index=>{:name=>"index_news_archives_on_created_at"}
    t.datetime "updated_at",     :index=>{:name=>"index_news_archives_on_updated_at"}
    t.datetime "deleted_at",     :index=>{:name=>"index_news_archives_on_deleted_at"}
    t.integer  "items_featured"
    t.integer  "items_max"
    t.boolean  "archived",       :default=>false
  end

  create_table "news_items", force: :cascade do |t|
    t.string   "title",            :null=>false
    t.text     "body",             :null=>false
    t.datetime "created_at",       :index=>{:name=>"index_news_items_on_created_at"}
    t.datetime "updated_at",       :index=>{:name=>"index_news_items_on_updated_at"}
    t.text     "preamble"
    t.datetime "deleted_at",       :index=>{:name=>"index_news_items_on_deleted_at"}
    t.string   "meta_description"
  end

  create_table "news_viewers", force: :cascade do |t|
    t.string   "title",          :null=>false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at",     :index=>{:name=>"index_news_viewers_on_deleted_at"}
    t.integer  "items_featured"
    t.integer  "items_max"
    t.boolean  "show_archives",  :default=>true
  end

  create_table "news_viewer_archives", force: :cascade do |t|
    t.integer "news_viewer_id",  :index=>{:name=>"fk__news_viewer_archives_news_viewer_id"}, :foreign_key=>{:references=>"news_viewers", :name=>"fk_news_viewer_archives_news_viewer_id", :on_update=>:no_action, :on_delete=>:cascade}
    t.integer "news_archive_id", :index=>{:name=>"fk__news_viewer_archives_news_archive_id"}, :foreign_key=>{:references=>"news_archives", :name=>"fk_news_viewer_archives_news_archive_id", :on_update=>:no_action, :on_delete=>:cascade}
  end
  add_index "news_viewer_archives", ["news_archive_id"], :name=>"index_news_viewer_archives_on_news_archive_id"
  add_index "news_viewer_archives", ["news_viewer_id"], :name=>"index_news_viewer_archives_on_news_viewer_id"

  create_table "news_viewer_items", force: :cascade do |t|
    t.integer "news_viewer_id", :index=>{:name=>"fk__news_viewer_items_news_viewer_id"}, :foreign_key=>{:references=>"news_viewers", :name=>"fk_news_viewer_items_news_viewer_id", :on_update=>:no_action, :on_delete=>:cascade}
    t.integer "news_item_id",   :index=>{:name=>"fk__news_viewer_items_news_item_id"}, :foreign_key=>{:references=>"news_items", :name=>"fk_news_viewer_items_news_item_id", :on_update=>:no_action, :on_delete=>:cascade}
    t.integer "position"
  end
  add_index "news_viewer_items", ["news_item_id"], :name=>"index_news_viewer_items_on_news_item_id"
  add_index "news_viewer_items", ["news_viewer_id"], :name=>"index_news_viewer_items_on_news_viewer_id"

  create_table "newsletter_archives", force: :cascade do |t|
    t.string   "title",              :null=>false
    t.text     "description"
    t.datetime "created_at",         :index=>{:name=>"index_newsletter_archives_on_created_at"}
    t.datetime "updated_at",         :index=>{:name=>"index_newsletter_archives_on_updated_at"}
    t.string   "from_email_address"
    t.datetime "deleted_at",         :index=>{:name=>"index_newsletter_archives_on_deleted_at"}
  end

  create_table "newsletter_archives_users", force: :cascade do |t|
    t.integer  "newsletter_archive_id", :index=>{:name=>"unique_index_on_newsletter_archive_and_user_ids", :with=>["user_id"], :unique=>true}, :foreign_key=>{:references=>"newsletter_archives", :name=>"newsletter_archives_users_newsletter_archive_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.integer  "user_id",               :foreign_key=>{:references=>"users", :name=>"newsletter_archives_users_user_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newsletter_editions", force: :cascade do |t|
    t.string   "title",                :null=>false
    t.text     "body",                 :null=>false
    t.datetime "created_at",           :index=>{:name=>"index_newsletter_editions_on_created_at"}
    t.datetime "updated_at",           :index=>{:name=>"index_newsletter_editions_on_updated_at"}
    t.string   "published",            :default=>"unpublished", :index=>{:name=>"index_newsletter_editions_on_published"}
    t.datetime "deleted_at",           :index=>{:name=>"index_newsletter_editions_on_deleted_at"}
    t.integer  "header_image_node_id"
  end

  create_table "newsletter_edition_items", force: :cascade do |t|
    t.integer  "newsletter_edition_id", :null=>false, :index=>{:name=>"index_newsletter_edition_items_on_newsletter_edition_id"}, :foreign_key=>{:references=>"newsletter_editions", :name=>"newsletter_edition_items_newsletter_edition_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.string   "item_type",             :null=>false, :index=>{:name=>"index_newsletter_edition_items_on_item_type_and_item_id", :with=>["item_id"]}
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

  create_table "opinions", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", :index=>{:name=>"index_opinions_on_created_at"}
    t.datetime "updated_at", :index=>{:name=>"index_opinions_on_updated_at"}
    t.string   "entry_1_1"
    t.string   "entry_1_2"
    t.string   "entry_1_3"
    t.string   "entry_1_4"
    t.string   "entry_2_1"
    t.string   "entry_2_2"
    t.string   "entry_2_3"
    t.string   "entry_2_4"
    t.string   "entry_3_1"
    t.string   "entry_3_2"
    t.string   "entry_3_3"
    t.string   "entry_3_4"
    t.datetime "deleted_at", :index=>{:name=>"index_opinions_on_deleted_at"}
    t.string   "subtitle"
  end

  create_table "opinion_entries", force: :cascade do |t|
    t.integer "feeling",     :null=>false
    t.integer "description", :null=>false
    t.string  "text"
    t.integer "opinion_id",  :null=>false, :index=>{:name=>"opinion_entries_on_opinion_id"}, :foreign_key=>{:references=>"opinions", :name=>"opinion_entries_opinion_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
  end

  create_table "pages", force: :cascade do |t|
    t.string   "title",            :null=>false
    t.text     "body",             :null=>false
    t.datetime "created_at",       :index=>{:name=>"index_pages_on_created_at"}
    t.datetime "updated_at",       :index=>{:name=>"index_pages_on_updated_at"}
    t.text     "preamble"
    t.datetime "deleted_at",       :index=>{:name=>"index_pages_on_deleted_at"}
    t.string   "meta_description"
  end

  create_table "poll_questions", force: :cascade do |t|
    t.string   "question",   :null=>false
    t.boolean  "active",     :default=>false, :index=>{:name=>"index_poll_questions_on_active"}
    t.datetime "created_at", :index=>{:name=>"index_poll_questions_on_created_at"}
    t.datetime "updated_at", :index=>{:name=>"index_poll_questions_on_updated_at"}
    t.datetime "deleted_at", :index=>{:name=>"index_poll_questions_on_deleted_at"}
  end

  create_table "poll_options", force: :cascade do |t|
    t.string   "text",             :null=>false
    t.integer  "poll_question_id", :null=>false, :index=>{:name=>"index_poll_options_on_poll_question_id"}, :foreign_key=>{:references=>"poll_questions", :name=>"poll_options_poll_question_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.datetime "created_at",       :index=>{:name=>"index_poll_options_on_created_at"}
    t.datetime "updated_at",       :index=>{:name=>"index_poll_options_on_updated_at"}
    t.integer  "number_of_votes",  :default=>0, :null=>false
  end

  create_table "polls", force: :cascade do |t|
    t.string   "title",          :null=>false
    t.datetime "created_at",     :index=>{:name=>"index_polls_on_created_at"}
    t.datetime "updated_at",     :index=>{:name=>"index_polls_on_updated_at"}
    t.boolean  "requires_login", :default=>false
    t.datetime "deleted_at",     :index=>{:name=>"index_polls_on_deleted_at"}
  end

  create_table "responses", force: :cascade do |t|
    t.integer  "contact_form_id", :index=>{:name=>"fk__responses_contact_form_id"}, :foreign_key=>{:references=>"contact_forms", :name=>"fk_responses_contact_form_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "ip"
    t.datetime "time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
  end

  create_table "response_fields", force: :cascade do |t|
    t.integer  "response_id",           :index=>{:name=>"fk__response_fields_response_id"}, :foreign_key=>{:references=>"responses", :name=>"fk_response_fields_response_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "contact_form_field_id", :index=>{:name=>"fk__response_fields_contact_form_field_id"}, :foreign_key=>{:references=>"contact_form_fields", :name=>"fk_response_fields_contact_form_field_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file"
  end

  create_table "role_assignments", force: :cascade do |t|
    t.integer  "user_id",    :index=>{:name=>"index_role_assignments_on_user_id_and_name", :with=>["name"]}, :foreign_key=>{:references=>"users", :name=>"role_assignments_user_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.integer  "node_id",    :index=>{:name=>"index_role_assignments_on_node_id_and_user_id", :with=>["user_id"], :unique=>true}, :foreign_key=>{:references=>"nodes", :name=>"role_assignments_node_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.string   "name",       :null=>false
    t.datetime "created_at", :index=>{:name=>"index_role_assignments_on_created_at"}
    t.datetime "updated_at", :index=>{:name=>"index_role_assignments_on_updated_at"}
  end

  create_table "search_pages", force: :cascade do |t|
    t.string   "title",      :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at", :index=>{:name=>"index_search_pages_on_deleted_at"}
  end

  create_table "sections", force: :cascade do |t|
    t.string   "title",                    :null=>false
    t.text     "description"
    t.datetime "created_at",               :index=>{:name=>"index_sections_on_created_at"}
    t.datetime "updated_at",               :index=>{:name=>"index_sections_on_updated_at"}
    t.integer  "frontpage_node_id",        :index=>{:name=>"index_sections_on_frontpage_node_id"}, :foreign_key=>{:references=>"nodes", :name=>"sections_frontpage_node_id_fkey", :on_update=>:no_action, :on_delete=>:nullify}
    t.string   "type"
    t.string   "domain",                   :index=>{:name=>"index_sections_on_domain", :unique=>true}
    t.string   "analytics_code"
    t.text     "expiration_email_body"
    t.string   "expiration_email_subject"
    t.datetime "deleted_at",               :index=>{:name=>"index_sections_on_deleted_at"}
    t.string   "piwik_site_id"
    t.string   "google_search_engine"
    t.string   "meta_description"
  end

  create_table "settings", force: :cascade do |t|
    t.string   "key",        :null=>false, :index=>{:name=>"index_settings_on_key"}
    t.string   "label"
    t.text     "value"
    t.boolean  "editable"
    t.boolean  "deletable"
    t.boolean  "deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "social_media_links_boxes", force: :cascade do |t|
    t.string   "title",         :null=>false
    t.string   "twitter_url"
    t.string   "facebook_url"
    t.string   "linkedin_url"
    t.string   "youtube_url"
    t.string   "flickr_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at",    :index=>{:name=>"index_social_media_links_boxes_on_deleted_at"}
    t.string   "instagram_url"
  end

  create_table "synonyms", force: :cascade do |t|
    t.string   "original",   :null=>false, :index=>{:name=>"index_synonyms_on_original_and_name", :with=>["name"], :unique=>true}
    t.string   "name",       :null=>false
    t.float    "weight",     :default=>0.25, :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "node_id",    :index=>{:name=>"fk__synonyms_node_id"}, :foreign_key=>{:references=>"nodes", :name=>"fk_synonyms_node_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name",           :index=>{:name=>"index_tags_on_name", :unique=>true}
    t.integer "taggings_count", :default=>0
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        :index=>{:name=>"fk__taggings_tag_id"}, :foreign_key=>{:references=>"tags", :name=>"fk_taggings_tag_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "taggable_id",   :index=>{:name=>"index_taggings_on_taggable_id_and_taggable_type_and_context", :with=>["taggable_type", "context"]}
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end
  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], :name=>"taggings_idx", :unique=>true

  create_table "themes", force: :cascade do |t|
    t.string   "title",      :null=>false
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at", :index=>{:name=>"index_themes_on_deleted_at"}
  end

  create_table "top_hits_pages", force: :cascade do |t|
    t.string   "title",       :null=>false
    t.text     "description"
    t.datetime "created_at",  :index=>{:name=>"index_top_hits_pages_on_created_at"}
    t.datetime "updated_at",  :index=>{:name=>"index_top_hits_pages_on_updated_at"}
    t.datetime "deleted_at",  :index=>{:name=>"index_top_hits_pages_on_deleted_at"}
  end

  create_table "user_categories", force: :cascade do |t|
    t.integer  "user_id",     :null=>false, :index=>{:name=>"fk__user_categories_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_user_categories_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "category_id", :null=>false, :index=>{:name=>"fk__user_categories_category_id"}
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "user_categories", ["user_id", "category_id"], :name=>"index_user_categories_on_user_id_and_category_id", :unique=>true

  create_table "user_poll_question_votes", force: :cascade do |t|
    t.integer  "user_id",          :index=>{:name=>"fk__user_poll_question_votes_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_user_poll_question_votes_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "poll_question_id", :index=>{:name=>"fk__user_poll_question_votes_poll_question_id"}, :foreign_key=>{:references=>"poll_questions", :name=>"fk_user_poll_question_votes_poll_question_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", force: :cascade do |t|
    t.integer  "versionable_id",   :index=>{:name=>"unique_index_on_versionable_type_and_number", :with=>["versionable_type", "number"], :unique=>true}
    t.string   "versionable_type"
    t.integer  "number"
    t.text     "yaml"
    t.datetime "created_at",       :index=>{:name=>"index_versions_on_created_at"}
    t.string   "status",           :null=>false, :index=>{:name=>"index_versions_on_status"}
    t.integer  "editor_id",        :index=>{:name=>"fk__versions_editor_id"}, :foreign_key=>{:references=>"users", :name=>"fk_versions_editor_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.text     "editor_comment"
  end
  add_index "versions", ["editor_id"], :name=>"index_versions_on_editor_id"
  add_index "versions", ["versionable_id", "versionable_type"], :name=>"index_on_versionable_type"

  create_table "weblog_archives", force: :cascade do |t|
    t.string   "title",       :null=>false
    t.text     "description"
    t.datetime "created_at",  :index=>{:name=>"index_weblog_archives_on_created_at"}
    t.datetime "updated_at",  :index=>{:name=>"index_weblog_archives_on_updated_at"}
    t.datetime "deleted_at",  :index=>{:name=>"index_weblog_archives_on_deleted_at"}
  end

  create_table "weblog_posts", force: :cascade do |t|
    t.string   "title",      :null=>false
    t.text     "body",       :null=>false
    t.text     "preamble"
    t.datetime "created_at", :index=>{:name=>"index_weblog_posts_on_created_at"}
    t.datetime "updated_at", :index=>{:name=>"index_weblog_posts_on_updated_at"}
    t.datetime "deleted_at", :index=>{:name=>"index_weblog_posts_on_deleted_at"}
  end

  create_table "weblogs", force: :cascade do |t|
    t.string   "title",       :null=>false
    t.text     "description"
    t.integer  "user_id",     :null=>false, :foreign_key=>{:references=>"users", :name=>"weblogs_user_id_fkey", :on_update=>:no_action, :on_delete=>:cascade}
    t.datetime "created_at",  :index=>{:name=>"index_weblogs_on_created_at"}
    t.datetime "updated_at",  :index=>{:name=>"index_weblogs_on_updated_at"}
    t.datetime "deleted_at",  :index=>{:name=>"index_weblogs_on_deleted_at"}
  end

end
