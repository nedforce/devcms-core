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

ActiveRecord::Schema.define(:version => 20130329114327) do

  create_table "abbreviations", :force => true do |t|
    t.string   "abbr",       :null => false
    t.string   "definition", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "node_id"
  end

  create_table "agenda_item_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agenda_item_categories", ["created_at"], :name => "index_agenda_item_categories_on_created_at"
  add_index "agenda_item_categories", ["name"], :name => "index_agenda_item_categories_on_name", :unique => true
  add_index "agenda_item_categories", ["updated_at"], :name => "index_agenda_item_categories_on_updated_at"

  create_table "agenda_items", :force => true do |t|
    t.integer  "agenda_item_category_id"
    t.string   "description",             :null => false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "duration"
    t.string   "chairman"
    t.string   "notary"
    t.string   "staff_member"
    t.integer  "speaking_rights"
    t.datetime "deleted_at"
  end

  add_index "agenda_items", ["agenda_item_category_id"], :name => "index_agenda_items_on_agenda_item_category_id"
  add_index "agenda_items", ["created_at"], :name => "index_agenda_items_on_created_at"
  add_index "agenda_items", ["deleted_at"], :name => "index_agenda_items_on_deleted_at"
  add_index "agenda_items", ["updated_at"], :name => "index_agenda_items_on_updated_at"

  create_table "alphabetic_indices", :force => true do |t|
    t.string   "title",                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type", :default => "Page"
    t.datetime "deleted_at"
  end

  add_index "alphabetic_indices", ["deleted_at"], :name => "index_alphabetic_indices_on_deleted_at"

  create_table "attachments", :force => true do |t|
    t.string   "title",        :null => false
    t.integer  "size",         :null => false
    t.string   "content_type", :null => false
    t.string   "filename",     :null => false
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "file"
  end

  add_index "attachments", ["created_at"], :name => "index_attachments_on_created_at"
  add_index "attachments", ["deleted_at"], :name => "index_attachments_on_deleted_at"
  add_index "attachments", ["parent_id"], :name => "index_attachments_on_parent_id"
  add_index "attachments", ["updated_at"], :name => "index_attachments_on_updated_at"

  create_table "calendars", :force => true do |t|
    t.string   "title",       :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "calendars", ["created_at"], :name => "index_calendars_on_created_at"
  add_index "calendars", ["deleted_at"], :name => "index_calendars_on_deleted_at"
  add_index "calendars", ["updated_at"], :name => "index_calendars_on_updated_at"

  create_table "carrousel_items", :force => true do |t|
    t.text     "excerpt"
    t.integer  "carrousel_id", :null => false
    t.string   "item_type",    :null => false
    t.integer  "item_id",      :null => false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "carrousel_items", ["carrousel_id"], :name => "index_carrousel_items_on_carrousel_id"
  add_index "carrousel_items", ["item_type", "item_id"], :name => "index_carrousel_items_on_item_type_and_item_id"

  create_table "carrousels", :force => true do |t|
    t.string   "title",                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_time"
    t.integer  "current_carrousel_item_id"
    t.datetime "last_cycled"
    t.integer  "animation"
    t.datetime "deleted_at"
    t.integer  "transition_time"
  end

  add_index "carrousels", ["deleted_at"], :name => "index_carrousels_on_deleted_at"

  create_table "categories", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "synonyms"
  end

  create_table "combined_calendar_nodes", :force => true do |t|
    t.integer "combined_calendar_id"
    t.integer "node_id"
  end

  add_index "combined_calendar_nodes", ["combined_calendar_id"], :name => "index_combined_calendar_nodes_on_combined_calendar_id"
  add_index "combined_calendar_nodes", ["node_id"], :name => "index_combined_calendar_nodes_on_node_id"

  create_table "combined_calendars", :force => true do |t|
    t.string   "title",       :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "combined_calendars", ["deleted_at"], :name => "index_combined_calendars_on_deleted_at"

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.integer  "commentable_id",                 :default => 0,  :null => false
    t.string   "commentable_type", :limit => 15, :default => "", :null => false
    t.integer  "user_id",                        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comment",                        :default => ""
    t.string   "user_name",                      :default => "", :null => false
  end

  add_index "comments", ["commentable_type", "commentable_id"], :name => "index_comments_on_commentable_type_and_commentable_id"
  add_index "comments", ["created_at"], :name => "index_comments_on_created_at"
  add_index "comments", ["updated_at"], :name => "index_comments_on_updated_at"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"
  add_index "comments", ["user_name"], :name => "index_comments_on_user_name"

  create_table "contact_boxes", :force => true do |t|
    t.string   "title",               :null => false
    t.text     "contact_information", :null => false
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
    t.datetime "deleted_at"
  end

  add_index "contact_boxes", ["deleted_at"], :name => "index_contact_boxes_on_deleted_at"

  create_table "contact_form_fields", :force => true do |t|
    t.string   "label",                              :null => false
    t.string   "field_type",                         :null => false
    t.integer  "position",                           :null => false
    t.boolean  "obligatory",      :default => false
    t.text     "default_value"
    t.integer  "contact_form_id",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contact_form_fields", ["contact_form_id", "position"], :name => "index_contact_form_fields_on_contact_form_id_and_position", :unique => true

  create_table "contact_forms", :force => true do |t|
    t.string   "title",                             :null => false
    t.string   "email_address",                     :null => false
    t.text     "description_before_contact_fields"
    t.text     "description_after_contact_fields"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "send_method"
    t.datetime "deleted_at"
  end

  add_index "contact_forms", ["deleted_at"], :name => "index_contact_forms_on_deleted_at"

  create_table "content_copies", :force => true do |t|
    t.integer  "copied_node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "content_copies", ["copied_node_id"], :name => "index_content_copies_on_copied_node_id"
  add_index "content_copies", ["created_at"], :name => "index_content_copies_on_created_at"
  add_index "content_copies", ["deleted_at"], :name => "index_content_copies_on_deleted_at"
  add_index "content_copies", ["updated_at"], :name => "index_content_copies_on_updated_at"

  create_table "content_representations", :force => true do |t|
    t.integer  "parent_id",   :null => false
    t.integer  "content_id"
    t.string   "target"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "custom_type"
  end

  add_index "content_representations", ["parent_id", "content_id"], :name => "index_content_representations_on_parent_id_and_content_id", :unique => true

  create_table "event_registrations", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.integer  "people_count"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "events", :force => true do |t|
    t.string   "title",                                   :null => false
    t.text     "body"
    t.string   "location_description"
    t.datetime "start_time",                              :null => false
    t.datetime "end_time",                                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "meeting_category_id"
    t.integer  "repeat_identifier"
    t.text     "dynamic_attributes"
    t.datetime "deleted_at"
    t.boolean  "subscription_enabled", :default => false
  end

  add_index "events", ["created_at"], :name => "index_calendar_items_on_created_at"
  add_index "events", ["deleted_at"], :name => "index_events_on_deleted_at"
  add_index "events", ["end_time"], :name => "index_calendar_items_on_end_time"
  add_index "events", ["meeting_category_id"], :name => "index_calendar_items_on_meeting_category_id"
  add_index "events", ["start_time"], :name => "index_calendar_items_on_start_time"
  add_index "events", ["updated_at"], :name => "index_calendar_items_on_updated_at"

  create_table "feeds", :force => true do |t|
    t.string   "url",                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.text     "cached_parsed_feed"
    t.binary   "xml"
    t.datetime "deleted_at"
  end

  add_index "feeds", ["created_at"], :name => "index_feeds_on_created_at"
  add_index "feeds", ["deleted_at"], :name => "index_feeds_on_deleted_at"
  add_index "feeds", ["updated_at"], :name => "index_feeds_on_updated_at"

  create_table "forum_posts", :force => true do |t|
    t.text     "body",                            :null => false
    t.integer  "forum_thread_id",                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "user_name",       :default => "", :null => false
  end

  add_index "forum_posts", ["created_at"], :name => "index_forum_posts_on_created_at"
  add_index "forum_posts", ["forum_thread_id"], :name => "index_forum_posts_on_forum_thread_id"
  add_index "forum_posts", ["updated_at"], :name => "index_forum_posts_on_updated_at"
  add_index "forum_posts", ["user_id"], :name => "index_forum_posts_on_user_id"
  add_index "forum_posts", ["user_name"], :name => "index_forum_posts_on_user_name"

  create_table "forum_threads", :force => true do |t|
    t.string   "title",                             :null => false
    t.integer  "user_id",                           :null => false
    t.integer  "forum_topic_id",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "closed",         :default => false, :null => false
  end

  add_index "forum_threads", ["created_at"], :name => "index_forum_threads_on_created_at"
  add_index "forum_threads", ["forum_topic_id"], :name => "index_forum_threads_on_forum_topic_id"
  add_index "forum_threads", ["updated_at"], :name => "index_forum_threads_on_updated_at"
  add_index "forum_threads", ["user_id"], :name => "index_forum_threads_on_user_id"

  create_table "forum_topics", :force => true do |t|
    t.string   "title",       :null => false
    t.text     "description", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "forum_topics", ["created_at"], :name => "index_forum_topics_on_created_at"
  add_index "forum_topics", ["deleted_at"], :name => "index_forum_topics_on_deleted_at"
  add_index "forum_topics", ["title"], :name => "index_forum_topics_on_title", :unique => true
  add_index "forum_topics", ["updated_at"], :name => "index_forum_topics_on_updated_at"

  create_table "forums", :force => true do |t|
    t.string   "title",       :null => false
    t.text     "description", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "forums", ["created_at"], :name => "index_forums_on_created_at"
  add_index "forums", ["deleted_at"], :name => "index_forums_on_deleted_at"
  add_index "forums", ["title"], :name => "index_forums_on_title", :unique => true
  add_index "forums", ["updated_at"], :name => "index_forums_on_updated_at"

  create_table "geo_viewer_placements", :force => true do |t|
    t.integer  "combined_geo_viewer_id"
    t.integer  "geo_viewer_id"
    t.boolean  "is_toggable"
    t.boolean  "is_toggled",             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geo_viewer_placements", ["combined_geo_viewer_id"], :name => "index_geo_viewer_placements_on_combined_geo_viewer_id"
  add_index "geo_viewer_placements", ["geo_viewer_id"], :name => "index_geo_viewer_placements_on_geo_viewer_id"

  create_table "geo_viewers", :force => true do |t|
    t.string   "title",           :null => false
    t.text     "description"
    t.text     "filter_settings"
    t.text     "map_settings"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "link_titles"
    t.boolean  "combined_viewer"
    t.boolean  "inherit_images"
    t.boolean  "inherit_pins"
  end

  add_index "geo_viewers", ["deleted_at"], :name => "index_geo_viewers_on_deleted_at"

  create_table "html_pages", :force => true do |t|
    t.string   "title",      :null => false
    t.text     "body",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "html_pages", ["created_at"], :name => "index_html_pages_on_created_at"
  add_index "html_pages", ["deleted_at"], :name => "index_html_pages_on_deleted_at"
  add_index "html_pages", ["updated_at"], :name => "index_html_pages_on_updated_at"

  create_table "images", :force => true do |t|
    t.string   "title",                              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alt"
    t.text     "description"
    t.string   "url"
    t.boolean  "is_for_header",   :default => false
    t.integer  "offset"
    t.datetime "deleted_at"
    t.boolean  "show_in_listing", :default => true,  :null => false
    t.string   "file"
  end

  add_index "images", ["created_at"], :name => "index_images_on_created_at"
  add_index "images", ["deleted_at"], :name => "index_images_on_deleted_at"
  add_index "images", ["updated_at"], :name => "index_images_on_updated_at"

  create_table "interests", :force => true do |t|
    t.string "title", :null => false
  end

  create_table "interests_users", :id => false, :force => true do |t|
    t.integer "interest_id"
    t.integer "user_id"
  end

  add_index "interests_users", ["user_id", "interest_id"], :name => "index_interests_users_on_user_id_and_interest_id"

  create_table "legislation_archives", :force => true do |t|
    t.string   "title",          :null => false
    t.text     "description"
    t.date     "last_import_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "legislation_archives", ["deleted_at"], :name => "index_legislation_archives_on_deleted_at"

  create_table "legislations", :force => true do |t|
    t.string   "identifier",  :null => false
    t.string   "title",       :null => false
    t.text     "body"
    t.date     "issued_at"
    t.date     "modified_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subject"
    t.string   "cite_title"
    t.datetime "deleted_at"
  end

  add_index "legislations", ["deleted_at"], :name => "index_legislations_on_deleted_at"
  add_index "legislations", ["identifier"], :name => "index_legislations_on_identifier"

  create_table "links", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "type"
    t.integer  "linked_node_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "links", ["created_at"], :name => "index_links_on_created_at"
  add_index "links", ["deleted_at"], :name => "index_links_on_deleted_at"
  add_index "links", ["linked_node_id"], :name => "index_links_on_linked_node_id"
  add_index "links", ["updated_at"], :name => "index_links_on_updated_at"

  create_table "links_boxes", :force => true do |t|
    t.string   "title",       :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "links_boxes", ["deleted_at"], :name => "index_links_boxes_on_deleted_at"

  create_table "login_attempts", :force => true do |t|
    t.string   "ip",                            :null => false
    t.string   "user_login"
    t.boolean  "success",    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "meeting_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "meeting_categories", ["created_at"], :name => "index_meeting_categories_on_created_at"
  add_index "meeting_categories", ["name"], :name => "index_meeting_categories_on_name", :unique => true
  add_index "meeting_categories", ["updated_at"], :name => "index_meeting_categories_on_updated_at"

  create_table "news_archives", :force => true do |t|
    t.string   "title",          :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "items_featured"
    t.integer  "items_max"
  end

  add_index "news_archives", ["created_at"], :name => "index_news_archives_on_created_at"
  add_index "news_archives", ["deleted_at"], :name => "index_news_archives_on_deleted_at"
  add_index "news_archives", ["updated_at"], :name => "index_news_archives_on_updated_at"

  create_table "news_items", :force => true do |t|
    t.string   "title",      :null => false
    t.text     "body",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "preamble"
    t.datetime "deleted_at"
  end

  add_index "news_items", ["created_at"], :name => "index_news_items_on_created_at"
  add_index "news_items", ["deleted_at"], :name => "index_news_items_on_deleted_at"
  add_index "news_items", ["updated_at"], :name => "index_news_items_on_updated_at"

  create_table "news_viewer_archives", :force => true do |t|
    t.integer "news_viewer_id"
    t.integer "news_archive_id"
  end

  add_index "news_viewer_archives", ["news_archive_id"], :name => "index_news_viewer_archives_on_news_archive_id"
  add_index "news_viewer_archives", ["news_viewer_id"], :name => "index_news_viewer_archives_on_news_viewer_id"

  create_table "news_viewer_items", :force => true do |t|
    t.integer "news_viewer_id"
    t.integer "news_item_id"
    t.integer "position"
  end

  add_index "news_viewer_items", ["news_item_id"], :name => "index_news_viewer_items_on_news_item_id"
  add_index "news_viewer_items", ["news_viewer_id"], :name => "index_news_viewer_items_on_news_viewer_id"

  create_table "news_viewers", :force => true do |t|
    t.string   "title",          :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "items_featured"
    t.integer  "items_max"
  end

  add_index "news_viewers", ["deleted_at"], :name => "index_news_viewers_on_deleted_at"

  create_table "newsletter_archives", :force => true do |t|
    t.string   "title",              :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "from_email_address"
    t.datetime "deleted_at"
  end

  add_index "newsletter_archives", ["created_at"], :name => "index_newsletter_archives_on_created_at"
  add_index "newsletter_archives", ["deleted_at"], :name => "index_newsletter_archives_on_deleted_at"
  add_index "newsletter_archives", ["updated_at"], :name => "index_newsletter_archives_on_updated_at"

  create_table "newsletter_archives_users", :id => false, :force => true do |t|
    t.integer "newsletter_archive_id"
    t.integer "user_id"
  end

  add_index "newsletter_archives_users", ["newsletter_archive_id", "user_id"], :name => "unique_index_on_newsletter_archive_and_user_ids", :unique => true

  create_table "newsletter_edition_items", :force => true do |t|
    t.integer  "newsletter_edition_id", :null => false
    t.string   "item_type",             :null => false
    t.integer  "item_id",               :null => false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "newsletter_edition_items", ["created_at"], :name => "index_newsletter_edition_items_on_created_at"
  add_index "newsletter_edition_items", ["item_type", "item_id"], :name => "index_newsletter_edition_items_on_item_type_and_item_id"
  add_index "newsletter_edition_items", ["newsletter_edition_id", "position"], :name => "index_on_edition_items_and_position"
  add_index "newsletter_edition_items", ["newsletter_edition_id"], :name => "index_newsletter_edition_items_on_newsletter_edition_id"
  add_index "newsletter_edition_items", ["updated_at"], :name => "index_newsletter_edition_items_on_updated_at"

  create_table "newsletter_edition_queues", :force => true do |t|
    t.integer  "newsletter_edition_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "newsletter_edition_queues", ["created_at"], :name => "index_newsletter_edition_queues_on_created_at"
  add_index "newsletter_edition_queues", ["newsletter_edition_id", "user_id"], :name => "unique_index_on_newsletter_edition_and_user_ids", :unique => true
  add_index "newsletter_edition_queues", ["updated_at"], :name => "index_newsletter_edition_queues_on_updated_at"

  create_table "newsletter_editions", :force => true do |t|
    t.string   "title",                                           :null => false
    t.text     "body",                                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "published",            :default => "unpublished"
    t.datetime "deleted_at"
    t.integer  "header_image_node_id"
  end

  add_index "newsletter_editions", ["created_at"], :name => "index_newsletter_editions_on_created_at"
  add_index "newsletter_editions", ["deleted_at"], :name => "index_newsletter_editions_on_deleted_at"
  add_index "newsletter_editions", ["published"], :name => "index_newsletter_editions_on_published"
  add_index "newsletter_editions", ["updated_at"], :name => "index_newsletter_editions_on_updated_at"

  create_table "node_categories", :force => true do |t|
    t.integer  "node_id",     :null => false
    t.integer  "category_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "node_categories", ["node_id", "category_id"], :name => "index_node_categories_on_node_id_and_category_id", :unique => true

  create_table "nodes", :force => true do |t|
    t.string   "content_type",                                          :null => false
    t.integer  "content_id",                                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "inherits_side_box_elements",     :default => true,      :null => false
    t.boolean  "private",                        :default => false
    t.string   "url_alias"
    t.boolean  "show_in_menu",                   :default => false,     :null => false
    t.boolean  "commentable",                    :default => false
    t.boolean  "has_changed_feed",               :default => false
    t.integer  "hits",                           :default => 0,         :null => false
    t.datetime "publication_start_date"
    t.datetime "publication_end_date"
    t.string   "content_box_title"
    t.string   "content_box_icon"
    t.string   "content_box_colour"
    t.integer  "content_box_number_of_items"
    t.string   "ancestry"
    t.integer  "position"
    t.string   "external_id"
    t.string   "layout"
    t.string   "layout_variant"
    t.text     "layout_configuration"
    t.float    "lat"
    t.float    "lng"
    t.string   "location"
    t.integer  "responsible_user_id"
    t.date     "expires_on"
    t.string   "custom_url_suffix"
    t.string   "custom_url_alias"
    t.boolean  "publishable",                    :default => false,     :null => false
    t.boolean  "hidden",                         :default => false,     :null => false
    t.integer  "ancestry_depth",                 :default => 0
    t.string   "sub_content_type",                                      :null => false
    t.string   "title"
    t.string   "expiration_notification_method", :default => "inherit"
    t.string   "expiration_email_recipient"
    t.datetime "deleted_at"
    t.integer  "pin_id"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "short_title"
    t.string   "locale"
  end

  add_index "nodes", ["ancestry"], :name => "index_nodes_on_ancestry"
  add_index "nodes", ["ancestry_depth"], :name => "index_nodes_on_ancestry_depth"
  add_index "nodes", ["content_type", "content_id"], :name => "index_nodes_on_content_type_and_content_id", :unique => true
  add_index "nodes", ["created_at"], :name => "index_nodes_on_created_at"
  add_index "nodes", ["custom_url_alias"], :name => "index_nodes_on_custom_url_alias"
  add_index "nodes", ["deleted_at"], :name => "index_nodes_on_deleted_at"
  add_index "nodes", ["external_id"], :name => "index_nodes_on_external_id"
  add_index "nodes", ["hidden"], :name => "index_nodes_on_hidden"
  add_index "nodes", ["hits"], :name => "index_nodes_on_hits"
  add_index "nodes", ["inherits_side_box_elements"], :name => "index_nodes_on_inherits_side_box_elements"
  add_index "nodes", ["lat", "lng"], :name => "index_nodes_on_lat_and_lng"
  add_index "nodes", ["position"], :name => "index_nodes_on_position"
  add_index "nodes", ["private"], :name => "index_nodes_on_private"
  add_index "nodes", ["publication_end_date"], :name => "index_nodes_on_publication_end_date"
  add_index "nodes", ["publication_start_date"], :name => "index_nodes_on_publication_start_date"
  add_index "nodes", ["publishable"], :name => "index_nodes_on_publishable"
  add_index "nodes", ["show_in_menu"], :name => "index_nodes_on_show_in_menu"
  add_index "nodes", ["sub_content_type"], :name => "index_nodes_on_sub_content_type"
  add_index "nodes", ["title"], :name => "index_nodes_on_title"
  add_index "nodes", ["updated_at"], :name => "index_nodes_on_updated_at"
  add_index "nodes", ["url_alias"], :name => "index_nodes_on_url_alias"

  create_table "opus_plus_importers", :force => true do |t|
    t.integer  "product_catalogue_id"
    t.string   "kid",                                                                      :null => false
    t.string   "lid",                  :default => "4a88d168-ef2e-4b7e-a992-cd5c513c19f6"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "title",      :null => false
    t.text     "body",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "preamble"
    t.datetime "deleted_at"
  end

  add_index "pages", ["created_at"], :name => "index_pages_on_created_at"
  add_index "pages", ["deleted_at"], :name => "index_pages_on_deleted_at"
  add_index "pages", ["updated_at"], :name => "index_pages_on_updated_at"

  create_table "permit_activities", :force => true do |t|
    t.integer  "permit_id",  :null => false
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permit_addresses", :force => true do |t|
    t.integer  "permit_id",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "postal_code"
    t.string   "house_number"
    t.string   "house_character"
    t.string   "complement"
  end

  create_table "permit_archives", :force => true do |t|
    t.string   "title",                              :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "publication_node_id"
    t.integer  "publication_number"
    t.text     "publication_notification_addresses"
    t.datetime "deleted_at"
  end

  add_index "permit_archives", ["deleted_at"], :name => "index_permit_archives_on_deleted_at"

  create_table "permit_coordinates", :force => true do |t|
    t.integer "permit_id", :null => false
    t.float   "x",         :null => false
    t.float   "y",         :null => false
    t.float   "z"
  end

  create_table "permit_parcels", :force => true do |t|
    t.integer  "permit_id",  :null => false
    t.string   "section",    :null => false
    t.string   "number",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permit_phase_product_descriptions", :force => true do |t|
    t.integer  "product_type_id"
    t.integer  "phase_id",        :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "paper_index"
  end

  create_table "permit_viewers", :force => true do |t|
    t.string   "title",              :null => false
    t.text     "description"
    t.string   "product_types"
    t.string   "phases"
    t.string   "period_types"
    t.string   "zip_codes"
    t.string   "population_centers"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "permit_viewers", ["deleted_at"], :name => "index_permit_viewers_on_deleted_at"

  create_table "permits", :force => true do |t|
    t.string   "title",                :null => false
    t.text     "description",          :null => false
    t.string   "company_number"
    t.string   "company_name"
    t.string   "company_address"
    t.string   "period_type"
    t.datetime "period_start_date"
    t.datetime "period_end_date"
    t.string   "reference"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "phase_id"
    t.string   "population_center"
    t.string   "announcement_number"
    t.string   "reference_number"
    t.date     "published_at"
    t.date     "submission_date"
    t.integer  "product_type_id"
    t.integer  "product_type_code_id"
    t.integer  "phase_code_id"
    t.date     "sent_at"
    t.datetime "deleted_at"
  end

  add_index "permits", ["announcement_number"], :name => "index_permits_on_announcement_number"
  add_index "permits", ["deleted_at"], :name => "index_permits_on_deleted_at"
  add_index "permits", ["population_center"], :name => "index_permits_on_population_center"
  add_index "permits", ["published_at"], :name => "index_permits_on_published_at"
  add_index "permits", ["reference_number"], :name => "index_permits_on_reference_number"

  create_table "pins", :force => true do |t|
    t.string "title"
    t.string "file"
  end

  create_table "poll_options", :force => true do |t|
    t.string   "text",                            :null => false
    t.integer  "poll_question_id",                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "number_of_votes",  :default => 0, :null => false
  end

  add_index "poll_options", ["created_at"], :name => "index_poll_options_on_created_at"
  add_index "poll_options", ["poll_question_id"], :name => "index_poll_options_on_poll_question_id"
  add_index "poll_options", ["updated_at"], :name => "index_poll_options_on_updated_at"

  create_table "poll_questions", :force => true do |t|
    t.string   "question",                      :null => false
    t.boolean  "active",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "poll_questions", ["active"], :name => "index_poll_questions_on_active"
  add_index "poll_questions", ["created_at"], :name => "index_poll_questions_on_created_at"
  add_index "poll_questions", ["deleted_at"], :name => "index_poll_questions_on_deleted_at"
  add_index "poll_questions", ["updated_at"], :name => "index_poll_questions_on_updated_at"

  create_table "polls", :force => true do |t|
    t.string   "title",                             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "requires_login", :default => false
    t.datetime "deleted_at"
  end

  add_index "polls", ["created_at"], :name => "index_polls_on_created_at"
  add_index "polls", ["deleted_at"], :name => "index_polls_on_deleted_at"
  add_index "polls", ["updated_at"], :name => "index_polls_on_updated_at"

  create_table "product_catalogues", :force => true do |t|
    t.string   "title",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.datetime "deleted_at"
  end

  add_index "product_catalogues", ["created_at"], :name => "index_product_catalogues_on_created_at"
  add_index "product_catalogues", ["deleted_at"], :name => "index_product_catalogues_on_deleted_at"
  add_index "product_catalogues", ["updated_at"], :name => "index_product_catalogues_on_updated_at"

  create_table "product_categories", :force => true do |t|
    t.string   "title",       :null => false
    t.text     "keywords"
    t.text     "description"
    t.string   "external_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
  end

  add_index "product_categories", ["ancestry"], :name => "index_product_categories_on_ancestry"
  add_index "product_categories", ["external_id"], :name => "index_product_categories_on_external_id", :unique => true

  create_table "product_categories_products", :force => true do |t|
    t.integer  "product_id"
    t.integer  "product_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_social_situations", :force => true do |t|
    t.string   "situation",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_social_situations", ["created_at"], :name => "index_product_social_situations_on_created_at"
  add_index "product_social_situations", ["situation"], :name => "index_product_social_situations_on_situation", :unique => true
  add_index "product_social_situations", ["updated_at"], :name => "index_product_social_situations_on_updated_at"

  create_table "product_synonyms", :force => true do |t|
    t.integer  "product_id"
    t.string   "synonym",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_synonyms", ["created_at"], :name => "index_product_synonyms_on_created_at"
  add_index "product_synonyms", ["product_id"], :name => "index_product_synonyms_on_product_id"
  add_index "product_synonyms", ["updated_at"], :name => "index_product_synonyms_on_updated_at"

  create_table "product_themes", :force => true do |t|
    t.string   "theme",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "external_id"
    t.integer  "parent_id"
    t.text     "keywords"
    t.text     "description"
  end

  add_index "product_themes", ["created_at"], :name => "index_product_themes_on_created_at"
  add_index "product_themes", ["parent_id", "theme"], :name => "index_product_themes_on_parent_id_and_theme", :unique => true
  add_index "product_themes", ["updated_at"], :name => "index_product_themes_on_updated_at"

  create_table "products", :force => true do |t|
    t.string   "title",                       :null => false
    t.integer  "product_theme_id"
    t.integer  "product_social_situation_id"
    t.text     "description"
    t.text     "delivery"
    t.text     "bring_along"
    t.text     "cost"
    t.text     "result"
    t.text     "legislation"
    t.text     "more_info"
    t.text     "forms"
    t.integer  "hits"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "extra"
    t.text     "summary"
    t.text     "conditions"
    t.text     "process"
    t.text     "background"
    t.text     "tips"
    t.text     "local_legislation"
    t.text     "authority"
    t.text     "actor"
    t.text     "references"
    t.text     "contacts"
    t.datetime "last_changed"
    t.string   "external_id"
    t.text     "external_url"
    t.datetime "deleted_at"
  end

  add_index "products", ["created_at"], :name => "index_products_on_created_at"
  add_index "products", ["deleted_at"], :name => "index_products_on_deleted_at"
  add_index "products", ["hits"], :name => "index_products_on_hits"
  add_index "products", ["product_social_situation_id"], :name => "index_products_on_product_social_situation_id"
  add_index "products", ["product_theme_id"], :name => "index_products_on_product_theme_id"
  add_index "products", ["title"], :name => "index_products_on_title"
  add_index "products", ["updated_at"], :name => "index_products_on_updated_at"

  create_table "research_archives", :force => true do |t|
    t.string   "title",          :null => false
    t.text     "description"
    t.text     "default_source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "research_archives", ["deleted_at"], :name => "index_research_archives_on_deleted_at"

  create_table "research_reports", :force => true do |t|
    t.string   "title",              :null => false
    t.text     "preamble"
    t.text     "description"
    t.text     "conclusions"
    t.date     "publication_date"
    t.boolean  "use_default_source"
    t.text     "source"
    t.string   "report_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "research_reports", ["deleted_at"], :name => "index_research_reports_on_deleted_at"

  create_table "research_themes", :force => true do |t|
    t.string   "title",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "response_fields", :force => true do |t|
    t.integer  "response_id"
    t.integer  "contact_form_field_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file"
  end

  create_table "responses", :force => true do |t|
    t.integer  "contact_form_id"
    t.string   "ip"
    t.datetime "time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
  end

  create_table "role_assignments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "node_id"
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "role_assignments", ["created_at"], :name => "index_role_assignments_on_created_at"
  add_index "role_assignments", ["node_id", "user_id"], :name => "index_role_assignments_on_node_id_and_user_id", :unique => true
  add_index "role_assignments", ["updated_at"], :name => "index_role_assignments_on_updated_at"
  add_index "role_assignments", ["user_id", "name"], :name => "index_role_assignments_on_user_id_and_name"

  create_table "search_pages", :force => true do |t|
    t.string   "title",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "search_pages", ["deleted_at"], :name => "index_search_pages_on_deleted_at"

  create_table "sections", :force => true do |t|
    t.string   "title",                    :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "frontpage_node_id"
    t.string   "type"
    t.string   "domain"
    t.string   "analytics_code"
    t.text     "expiration_email_body"
    t.string   "expiration_email_subject"
    t.datetime "deleted_at"
    t.string   "piwik_site_id"
  end

  add_index "sections", ["created_at"], :name => "index_sections_on_created_at"
  add_index "sections", ["deleted_at"], :name => "index_sections_on_deleted_at"
  add_index "sections", ["domain"], :name => "index_sections_on_domain", :unique => true
  add_index "sections", ["frontpage_node_id"], :name => "index_sections_on_frontpage_node_id"
  add_index "sections", ["updated_at"], :name => "index_sections_on_updated_at"

  create_table "settings", :force => true do |t|
    t.string   "key",        :null => false
    t.string   "alt"
    t.text     "value"
    t.boolean  "editable"
    t.boolean  "deletable"
    t.boolean  "deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["key"], :name => "index_settings_on_key"

  create_table "share_point_lists", :force => true do |t|
    t.string   "guid",              :null => false
    t.string   "last_change_token"
    t.integer  "node_id",           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "paging_token"
    t.string   "site"
  end

  add_index "share_point_lists", ["guid"], :name => "index_share_point_lists_on_guid", :unique => true
  add_index "share_point_lists", ["node_id"], :name => "index_share_point_lists_on_node_id"

  create_table "social_media_links_boxes", :force => true do |t|
    t.string   "title",        :null => false
    t.string   "twitter_url"
    t.string   "hyves_url"
    t.string   "facebook_url"
    t.string   "linkedin_url"
    t.string   "youtube_url"
    t.string   "flickr_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "social_media_links_boxes", ["deleted_at"], :name => "index_social_media_links_boxes_on_deleted_at"

  create_table "synonyms", :force => true do |t|
    t.string   "original",                     :null => false
    t.string   "name",                         :null => false
    t.float    "weight",     :default => 0.25, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "node_id"
  end

  add_index "synonyms", ["original", "name"], :name => "index_synonyms_on_original_and_name", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "themes", :force => true do |t|
    t.string   "title",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",       :null => false
    t.datetime "deleted_at"
  end

  add_index "themes", ["deleted_at"], :name => "index_themes_on_deleted_at"

  create_table "top_hits_pages", :force => true do |t|
    t.string   "title",       :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "top_hits_pages", ["created_at"], :name => "index_top_hits_pages_on_created_at"
  add_index "top_hits_pages", ["deleted_at"], :name => "index_top_hits_pages_on_deleted_at"
  add_index "top_hits_pages", ["updated_at"], :name => "index_top_hits_pages_on_updated_at"

  create_table "tweets", :force => true do |t|
    t.integer  "sid",               :limit => 8
    t.string   "screen_name"
    t.string   "name"
    t.text     "text"
    t.string   "source"
    t.string   "profile_image_url"
    t.boolean  "hidden",                         :default => false
    t.integer  "twitter_box_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tweets", ["created_at"], :name => "index_tweets_on_created_at"
  add_index "tweets", ["screen_name", "hidden"], :name => "index_tweets_on_screen_name_and_hidden"
  add_index "tweets", ["sid"], :name => "index_tweets_on_sid"

  create_table "twitter_boxes", :force => true do |t|
    t.string   "title",      :null => false
    t.string   "hashtags"
    t.string   "accounts"
    t.boolean  "dutch_only"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "twitter_boxes", ["deleted_at"], :name => "index_twitter_boxes_on_deleted_at"

  create_table "user_categories", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "category_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_categories", ["user_id", "category_id"], :name => "index_user_categories_on_user_id_and_category_id", :unique => true

  create_table "user_poll_question_votes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "poll_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                                        :null => false
    t.string   "email_address",                                :null => false
    t.string   "password_hash",                                :null => false
    t.string   "password_salt",                                :null => false
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "verified",                  :default => false, :null => false
    t.string   "verification_code",         :default => "-",   :null => false
    t.string   "first_name"
    t.string   "surname"
    t.string   "sex"
    t.string   "password_reset_token"
    t.datetime "password_reset_expiration"
    t.boolean  "blocked",                   :default => false
    t.integer  "failed_logins",             :default => 0
    t.string   "type"
    t.string   "remember_token_ip"
  end

  add_index "users", ["created_at"], :name => "index_users_on_created_at"
  add_index "users", ["email_address"], :name => "index_users_on_email_address", :unique => true
  add_index "users", ["first_name"], :name => "index_users_on_first_name"
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"
  add_index "users", ["sex"], :name => "index_users_on_sex"
  add_index "users", ["surname"], :name => "index_users_on_surname"
  add_index "users", ["updated_at"], :name => "index_users_on_updated_at"
  add_index "users", ["verified"], :name => "index_users_on_verified"

  create_table "versions", :force => true do |t|
    t.integer  "versionable_id"
    t.string   "versionable_type"
    t.integer  "number"
    t.text     "yaml"
    t.datetime "created_at"
    t.string   "status",           :null => false
    t.integer  "editor_id"
    t.text     "editor_comment"
  end

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["editor_id"], :name => "index_versions_on_editor_id"
  add_index "versions", ["status"], :name => "index_versions_on_status"
  add_index "versions", ["versionable_id", "versionable_type", "number"], :name => "unique_index_on_versionable_type_and_number", :unique => true
  add_index "versions", ["versionable_id", "versionable_type"], :name => "index_on_versionable_type"

  create_table "weblog_archives", :force => true do |t|
    t.string   "title",       :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "weblog_archives", ["created_at"], :name => "index_weblog_archives_on_created_at"
  add_index "weblog_archives", ["deleted_at"], :name => "index_weblog_archives_on_deleted_at"
  add_index "weblog_archives", ["updated_at"], :name => "index_weblog_archives_on_updated_at"

  create_table "weblog_posts", :force => true do |t|
    t.string   "title",      :null => false
    t.text     "body",       :null => false
    t.text     "preamble"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "weblog_posts", ["created_at"], :name => "index_weblog_posts_on_created_at"
  add_index "weblog_posts", ["deleted_at"], :name => "index_weblog_posts_on_deleted_at"
  add_index "weblog_posts", ["updated_at"], :name => "index_weblog_posts_on_updated_at"

  create_table "weblogs", :force => true do |t|
    t.string   "title",       :null => false
    t.text     "description"
    t.integer  "user_id",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "weblogs", ["created_at"], :name => "index_weblogs_on_created_at"
  add_index "weblogs", ["deleted_at"], :name => "index_weblogs_on_deleted_at"
  add_index "weblogs", ["updated_at"], :name => "index_weblogs_on_updated_at"

  add_foreign_key "combined_calendar_nodes", ["combined_calendar_id"], "combined_calendars", ["id"], :name => "combined_calendar_nodes_combined_calendar_id_fkey"
  add_foreign_key "combined_calendar_nodes", ["node_id"], "nodes", ["id"], :name => "combined_calendar_nodes_node_id_fkey"

  add_foreign_key "event_registrations", ["event_id"], "events", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "event_registrations_event_id_fkey"
  add_foreign_key "event_registrations", ["user_id"], "users", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "event_registrations_user_id_fkey"

  add_foreign_key "geo_viewer_placements", ["combined_geo_viewer_id"], "geo_viewers", ["id"], :name => "geo_viewer_placements_combined_geo_viewer_id_fkey"
  add_foreign_key "geo_viewer_placements", ["geo_viewer_id"], "geo_viewers", ["id"], :name => "geo_viewer_placements_geo_viewer_id_fkey"

  add_foreign_key "nodes", ["created_by_id"], "users", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "nodes_created_by_id_fkey"
  add_foreign_key "nodes", ["updated_by_id"], "users", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "nodes_updated_by_id_fkey"

  add_foreign_key "tweets", ["twitter_box_id"], "twitter_boxes", ["id"], :name => "tweets_twitter_box_id_fkey"

end
