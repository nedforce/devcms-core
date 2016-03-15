class CreateDevcmsBaseTables < ActiveRecord::Migration
  def up
    create_table "abbreviations", :force => true do |t|
      t.string   "abbr",       :null => false
      t.string   "definition", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
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
      t.integer  "calendar_item_id",        :null => false, :references => nil
      t.integer  "agenda_item_category_id", :references => nil
      t.string   "description",             :null => false
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "duration"
      t.string   "chairman"
      t.string   "notary"
      t.string   "staff_member"
      t.integer  "speaking_rights"
    end

    add_index "agenda_items", ["agenda_item_category_id"], :name => "index_agenda_items_on_agenda_item_category_id"
    add_index "agenda_items", ["calendar_item_id"], :name => "index_agenda_items_on_calendar_item_id"
    add_index "agenda_items", ["created_at"], :name => "index_agenda_items_on_created_at"
    add_index "agenda_items", ["updated_at"], :name => "index_agenda_items_on_updated_at"

    create_table "attachments", :force => true do |t|
      t.string   "title",        :null => false
      t.integer  "size",         :null => false
      t.string   "content_type", :null => false
      t.string   "filename",     :null => false
      t.integer  "height"
      t.integer  "width"
      t.integer  "parent_id", :references => nil
      t.string   "thumbnail"
      t.integer  "db_file_id", :references => nil
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "attachments", ["created_at"], :name => "index_attachments_on_created_at"
    add_index "attachments", ["db_file_id"], :name => "index_attachments_on_db_file_id", :unique => true
    add_index "attachments", ["parent_id"], :name => "index_attachments_on_parent_id"
    add_index "attachments", ["updated_at"], :name => "index_attachments_on_updated_at"

    create_table "calendar_items", :force => true do |t|
      t.string   "title",               :null => false
      t.text     "body"
      t.string   "location"
      t.datetime "start_time",          :null => false
      t.datetime "end_time",            :null => false
      t.integer  "calendar_id",         :null => false, :references => nil
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "type"
      t.integer  "meeting_category_id", :references => nil
      t.integer  "repeat_identifier"
    end

    add_index "calendar_items", ["calendar_id"], :name => "index_calendar_items_on_calendar_id"
    add_index "calendar_items", ["created_at"], :name => "index_calendar_items_on_created_at"
    add_index "calendar_items", ["end_time"], :name => "index_calendar_items_on_end_time"
    add_index "calendar_items", ["meeting_category_id"], :name => "index_calendar_items_on_meeting_category_id"
    add_index "calendar_items", ["start_time"], :name => "index_calendar_items_on_start_time"
    add_index "calendar_items", ["updated_at"], :name => "index_calendar_items_on_updated_at"

    create_table "calendars", :force => true do |t|
      t.string   "title",       :null => false
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "calendars", ["created_at"], :name => "index_calendars_on_created_at"
    add_index "calendars", ["updated_at"], :name => "index_calendars_on_updated_at"

    create_table "categories", :force => true do |t|
      t.string   "name",       :null => false
      t.integer  "parent_id", :references => nil
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "combined_calendars", :force => true do |t|
      t.string   "title",       :null => false
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "comments", :force => true do |t|
      t.string   "title",            :limit => 50, :default => ""
      t.integer  "commentable_id",                 :default => 0,  :null => false, :references => nil
      t.string   "commentable_type", :limit => 15, :default => "", :null => false
      t.integer  "user_id",                        :default => 0, :references => nil
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
      t.string   "title",                   :null => false
      t.text     "contact_information",     :null => false
      t.string   "monday_opening_hours",    :null => false
      t.string   "tuesday_opening_hours",   :null => false
      t.string   "wednesday_opening_hours", :null => false
      t.string   "thursday_opening_hours",  :null => false
      t.string   "friday_opening_hours",    :null => false
      t.string   "saturday_opening_hours",  :null => false
      t.string   "sunday_opening_hours",    :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "contact_form_fields", :force => true do |t|
      t.string   "label",                              :null => false
      t.string   "field_type",                         :null => false
      t.integer  "position",                           :null => false
      t.boolean  "obligatory",      :default => false
      t.string   "default_value"
      t.integer  "contact_form_id",                    :null => false, :references => nil
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
    end

    create_table "content_copies", :force => true do |t|
      t.integer  "copied_node_id", :references => nil
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "content_copies", ["copied_node_id"], :name => "index_content_copies_on_copied_node_id"
    add_index "content_copies", ["created_at"], :name => "index_content_copies_on_created_at"
    add_index "content_copies", ["updated_at"], :name => "index_content_copies_on_updated_at"

    create_table "db_files", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "loid"
    end

    add_index "db_files", ["created_at"], :name => "index_db_files_on_created_at"
    add_index "db_files", ["updated_at"], :name => "index_db_files_on_updated_at"

    create_table "feeds", :force => true do |t|
      t.string   "url",                :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "title"
      t.text     "cached_parsed_feed"
      t.binary   "xml"
    end

    add_index "feeds", ["created_at"], :name => "index_feeds_on_created_at"
    add_index "feeds", ["updated_at"], :name => "index_feeds_on_updated_at"

    create_table "forum_posts", :force => true do |t|
      t.text     "body",                            :null => false
      t.integer  "forum_thread_id",                 :null => false, :references => nil
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id", :references => nil
      t.string   "user_name",       :default => "", :null => false
    end

    add_index "forum_posts", ["created_at"], :name => "index_forum_posts_on_created_at"
    add_index "forum_posts", ["forum_thread_id"], :name => "index_forum_posts_on_forum_thread_id"
    add_index "forum_posts", ["updated_at"], :name => "index_forum_posts_on_updated_at"
    add_index "forum_posts", ["user_id"], :name => "index_forum_posts_on_user_id"
    add_index "forum_posts", ["user_name"], :name => "index_forum_posts_on_user_name"

    create_table "forum_threads", :force => true do |t|
      t.string   "title",                             :null => false
      t.integer  "user_id",                           :null => false, :references => nil
      t.integer  "forum_topic_id",                    :null => false, :references => nil
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
      t.integer  "forum_id",    :null => false, :references => nil
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "forum_topics", ["created_at"], :name => "index_forum_topics_on_created_at"
    add_index "forum_topics", ["forum_id"], :name => "index_forum_topics_on_forum_id"
    add_index "forum_topics", ["title"], :name => "index_forum_topics_on_title", :unique => true
    add_index "forum_topics", ["updated_at"], :name => "index_forum_topics_on_updated_at"

    create_table "forums", :force => true do |t|
      t.string   "title",       :null => false
      t.text     "description", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "forums", ["created_at"], :name => "index_forums_on_created_at"
    add_index "forums", ["title"], :name => "index_forums_on_title", :unique => true
    add_index "forums", ["updated_at"], :name => "index_forums_on_updated_at"

    create_table "html_pages", :force => true do |t|
      t.string   "title",      :null => false
      t.text     "body",       :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "html_pages", ["created_at"], :name => "index_html_pages_on_created_at"
    add_index "html_pages", ["updated_at"], :name => "index_html_pages_on_updated_at"

    create_table "images", :force => true do |t|
      t.binary   "data",                             :null => false
      t.string   "title",                            :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "alt"
      t.text     "description"
      t.string   "url"
      t.boolean  "is_for_header", :default => false
    end

    add_index "images", ["created_at"], :name => "index_images_on_created_at"
    add_index "images", ["updated_at"], :name => "index_images_on_updated_at"

    create_table "interests", :force => true do |t|
      t.string "title", :null => false
    end

    create_table "interests_users", :id => false, :force => true do |t|
      t.integer "interest_id", :references => nil
      t.integer "user_id", :references => nil
    end

    add_index "interests_users", ["user_id", "interest_id"], :name => "index_interests_users_on_user_id_and_interest_id"

    create_table "links", :force => true do |t|
      t.string   "title"
      t.string   "description"
      t.string   "type"
      t.integer  "linked_node_id", :references => nil
      t.string   "url"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "links", ["created_at"], :name => "index_links_on_created_at"
    add_index "links", ["linked_node_id"], :name => "index_links_on_linked_node_id"
    add_index "links", ["updated_at"], :name => "index_links_on_updated_at"

    create_table "meeting_categories", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "meeting_categories", ["created_at"], :name => "index_meeting_categories_on_created_at"
    add_index "meeting_categories", ["name"], :name => "index_meeting_categories_on_name", :unique => true
    add_index "meeting_categories", ["updated_at"], :name => "index_meeting_categories_on_updated_at"

    create_table "news_archives", :force => true do |t|
      t.string   "title",       :null => false
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "news_archives", ["created_at"], :name => "index_news_archives_on_created_at"
    add_index "news_archives", ["updated_at"], :name => "index_news_archives_on_updated_at"

    create_table "news_items", :force => true do |t|
      t.string   "title",           :null => false
      t.text     "body",            :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "news_archive_id", :references => nil
      t.text     "preamble"
    end

    add_index "news_items", ["created_at"], :name => "index_news_items_on_created_at"
    add_index "news_items", ["news_archive_id"], :name => "index_news_items_on_news_archive_id"
    add_index "news_items", ["updated_at"], :name => "index_news_items_on_updated_at"

    create_table "newsletter_archives", :force => true do |t|
      t.string   "title",              :null => false
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "from_email_address"
    end

    add_index "newsletter_archives", ["created_at"], :name => "index_newsletter_archives_on_created_at"
    add_index "newsletter_archives", ["updated_at"], :name => "index_newsletter_archives_on_updated_at"

    create_table "newsletter_archives_users", :id => false, :force => true do |t|
      t.integer "newsletter_archive_id", :references => nil
      t.integer "user_id", :references => nil
    end

    add_index "newsletter_archives_users", ["newsletter_archive_id", "user_id"], :name => "unique_index_on_newsletter_archive_and_user_ids", :unique => true

    create_table "newsletter_edition_items", :force => true do |t|
      t.integer  "newsletter_edition_id", :null => false, :references => nil
      t.string   "item_type",             :null => false
      t.integer  "item_id",               :null => false, :references => nil
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "newsletter_edition_items", ["created_at"], :name => "index_newsletter_edition_items_on_created_at"
    add_index "newsletter_edition_items", ["item_type", "item_id"], :name => "index_newsletter_edition_items_on_item_type_and_item_id"
    add_index "newsletter_edition_items", ["newsletter_edition_id"], :name => "index_newsletter_edition_items_on_newsletter_edition_id"
    add_index "newsletter_edition_items", ["updated_at"], :name => "index_newsletter_edition_items_on_updated_at"
    add_index "newsletter_edition_items", ["newsletter_edition_id", "position"], :name => "index_on_edition_items_and_position"

    create_table "newsletter_edition_queues", :force => true do |t|
      t.integer  "newsletter_edition_id", :references => nil
      t.integer  "user_id", :references => nil
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "newsletter_edition_queues", ["created_at"], :name => "index_newsletter_edition_queues_on_created_at"
    add_index "newsletter_edition_queues", ["updated_at"], :name => "index_newsletter_edition_queues_on_updated_at"
    add_index "newsletter_edition_queues", ["newsletter_edition_id", "user_id"], :name => "unique_index_on_newsletter_edition_and_user_ids", :unique => true

    create_table "newsletter_editions", :force => true do |t|
      t.integer  "newsletter_archive_id", :references => nil
      t.string   "title",                                            :null => false
      t.text     "body",                                             :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "published",             :default => "unpublished"
    end

    add_index "newsletter_editions", ["created_at"], :name => "index_newsletter_editions_on_created_at"
    add_index "newsletter_editions", ["newsletter_archive_id"], :name => "index_newsletter_editions_on_newsletter_archive_id"
    add_index "newsletter_editions", ["published"], :name => "index_newsletter_editions_on_published"
    add_index "newsletter_editions", ["updated_at"], :name => "index_newsletter_editions_on_updated_at"

    create_table "nodes", :force => true do |t|
      t.string   "content_type",                                        :null => false
      t.integer  "content_id",                                          :null => false, :references => nil
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "parent_id", :references => nil
      t.integer  "lft"
      t.integer  "rgt"
      t.integer  "template_id", :references => nil
      t.boolean  "inherits_side_box_elements",  :default => true,       :null => false
      t.boolean  "hidden",                      :default => false
      t.string   "url_alias"
      t.string   "status",                      :default => "approved"
      t.integer  "edited_by"
      t.boolean  "show_in_menu",                :default => false,      :null => false
      t.boolean  "commentable",                 :default => false
      t.boolean  "has_changed_feed",            :default => false
      t.boolean  "hide_right_column",           :default => false
      t.text     "editor_comment"
      t.integer  "hits",                        :default => 0,          :null => false
      t.datetime "publication_start_date"
      t.datetime "publication_end_date"
      t.boolean  "columns_mode",                :default => false
      t.string   "content_box_title"
      t.string   "content_box_icon"
      t.string   "content_box_colour"
      t.integer  "content_box_number_of_items"
      t.integer  "category_id", :references => nil
    end

    add_index "nodes", ["category_id"], :name => "index_nodes_on_category_id"
    add_index "nodes", ["content_type", "content_id"], :name => "index_nodes_on_content_type_and_content_id", :unique => true
    add_index "nodes", ["created_at"], :name => "index_nodes_on_created_at"
    add_index "nodes", ["hidden"], :name => "index_nodes_on_hidden"
    add_index "nodes", ["hits"], :name => "index_nodes_on_hits"
    add_index "nodes", ["inherits_side_box_elements"], :name => "index_nodes_on_inherits_side_box_elements"
    add_index "nodes", ["lft"], :name => "index_nodes_on_lft"
    add_index "nodes", ["lft", "rgt"], :name => "index_nodes_on_lft_and_rgt"
    add_index "nodes", ["parent_id"], :name => "index_nodes_on_parent_id"
    add_index "nodes", ["publication_end_date"], :name => "index_nodes_on_publication_end_date"
    add_index "nodes", ["publication_start_date"], :name => "index_nodes_on_publication_start_date"
    add_index "nodes", ["rgt"], :name => "index_nodes_on_rgt"
    add_index "nodes", ["show_in_menu"], :name => "index_nodes_on_show_in_menu"
    add_index "nodes", ["template_id"], :name => "index_nodes_on_template_id"
    add_index "nodes", ["updated_at"], :name => "index_nodes_on_updated_at"
    add_index "nodes", ["url_alias"], :name => "index_nodes_on_url_alias"

    create_table "pages", :force => true do |t|
      t.string   "title",      :null => false
      t.text     "body",       :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "preamble"
    end

    add_index "pages", ["created_at"], :name => "index_pages_on_created_at"
    add_index "pages", ["updated_at"], :name => "index_pages_on_updated_at"

    create_table "poll_options", :force => true do |t|
      t.string   "text",                            :null => false
      t.integer  "poll_question_id",                :null => false, :references => nil
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
      t.integer  "poll_id",                       :null => false, :references => nil
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "poll_questions", ["active"], :name => "index_poll_questions_on_active"
    add_index "poll_questions", ["created_at"], :name => "index_poll_questions_on_created_at"
    add_index "poll_questions", ["poll_id"], :name => "index_poll_questions_on_poll_id"
    add_index "poll_questions", ["updated_at"], :name => "index_poll_questions_on_updated_at"

    create_table "polls", :force => true do |t|
      t.string   "title",      :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "polls", ["created_at"], :name => "index_polls_on_created_at"
    add_index "polls", ["updated_at"], :name => "index_polls_on_updated_at"

    create_table "role_assignments", :force => true do |t|
      t.integer  "user_id", :references => nil
      t.integer  "node_id", :references => nil
      t.string   "name",       :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "role_assignments", ["created_at"], :name => "index_role_assignments_on_created_at"
    add_index "role_assignments", ["node_id", "user_id"], :name => "index_role_assignments_on_node_id_and_user_id", :unique => true
    add_index "role_assignments", ["updated_at"], :name => "index_role_assignments_on_updated_at"
    add_index "role_assignments", ["user_id", "name"], :name => "index_role_assignments_on_user_id_and_name"

    create_table "sections", :force => true do |t|
      t.string   "title",             :null => false
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "frontpage_node_id", :references => nil
    end

    add_index "sections", ["created_at"], :name => "index_sections_on_created_at"
    add_index "sections", ["frontpage_node_id"], :name => "index_sections_on_frontpage_node_id"
    add_index "sections", ["updated_at"], :name => "index_sections_on_updated_at"

    create_table "side_box_elements", :force => true do |t|
      t.integer  "parent_id",  :null => false, :references => nil
      t.integer  "content_id", :null => false, :references => nil
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "v_position"
      t.integer  "h_position"
    end

    add_index "side_box_elements", ["created_at"], :name => "index_side_box_elements_on_created_at"
    add_index "side_box_elements", ["h_position"], :name => "index_side_box_elements_on_h_position"
    add_index "side_box_elements", ["parent_id", "content_id"], :name => "index_side_box_elements_on_parent_id_and_content_id", :unique => true
    add_index "side_box_elements", ["updated_at"], :name => "index_side_box_elements_on_updated_at"
    add_index "side_box_elements", ["v_position"], :name => "index_side_box_elements_on_v_position"

    create_table "synonyms", :force => true do |t|
      t.string   "original",                     :null => false
      t.string   "name",                         :null => false
      t.float    "weight",     :default => 0.25, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "synonyms", ["original", "name"], :name => "index_synonyms_on_original_and_name", :unique => true

    create_table "templates", :force => true do |t|
      t.string   "title",       :null => false
      t.string   "description"
      t.string   "filename",    :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "templates", ["created_at"], :name => "index_templates_on_created_at"
    add_index "templates", ["filename"], :name => "index_templates_on_filename", :unique => true
    add_index "templates", ["title"], :name => "index_templates_on_title", :unique => true
    add_index "templates", ["updated_at"], :name => "index_templates_on_updated_at"

    create_table "top_hits_pages", :force => true do |t|
      t.string   "title",       :null => false
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "top_hits_pages", ["created_at"], :name => "index_top_hits_pages_on_created_at"
    add_index "top_hits_pages", ["updated_at"], :name => "index_top_hits_pages_on_updated_at"

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
      t.integer  "versionable_id", :references => nil
      t.string   "versionable_type"
      t.integer  "number"
      t.text     "yaml"
      t.datetime "created_at"
    end

    add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
    add_index "versions", ["versionable_id", "versionable_type", "number"], :name => "unique_index_on_versionable_type_and_number", :unique => true

    create_table "weblog_archives", :force => true do |t|
      t.string   "title",       :null => false
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "weblog_archives", ["created_at"], :name => "index_weblog_archives_on_created_at"
    add_index "weblog_archives", ["updated_at"], :name => "index_weblog_archives_on_updated_at"

    create_table "weblog_posts", :force => true do |t|
      t.string   "title",      :null => false
      t.text     "body",       :null => false
      t.text     "preamble"
      t.integer  "weblog_id",  :null => false, :references => nil
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "weblog_posts", ["created_at"], :name => "index_weblog_posts_on_created_at"
    add_index "weblog_posts", ["updated_at"], :name => "index_weblog_posts_on_updated_at"
    add_index "weblog_posts", ["weblog_id"], :name => "index_weblog_posts_on_weblog_id"

    create_table "weblogs", :force => true do |t|
      t.string   "title",             :null => false
      t.text     "description"
      t.integer  "user_id",           :null => false, :references => nil
      t.integer  "weblog_archive_id", :null => false, :references => nil
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "weblogs", ["created_at"], :name => "index_weblogs_on_created_at"
    add_index "weblogs", ["updated_at"], :name => "index_weblogs_on_updated_at"
    add_index "weblogs", ["weblog_archive_id", "user_id"], :name => "index_weblogs_on_weblog_archive_id_and_user_id", :unique => true

    add_foreign_key "agenda_items", "calendar_items", :on_delete => :cascade, :name => "agenda_items_calendar_item_id_fkey"
    add_foreign_key "agenda_items", "agenda_item_categories", :on_delete => :cascade, :name => "agenda_items_agenda_item_category_id_fkey"

    add_foreign_key "attachments", "attachments", :column => "parent_id", :on_delete => :cascade, :name => "attachments_parent_id_fkey"
    add_foreign_key "attachments", "db_files", :on_delete => :cascade, :name => "attachments_db_file_id_fkey"

    add_foreign_key "calendar_items", "calendars", :on_delete => :cascade, :name => "calendar_items_calendar_id_fkey"
    add_foreign_key "calendar_items", "meeting_categories", :on_delete => :cascade, :name => "calendar_items_meeting_category_id_fkey"

    add_foreign_key "categories", "categories", :column => "parent_id", :on_delete => :cascade, :name => "categories_parent_id_fkey"

    add_foreign_key "contact_form_fields", "contact_forms", :on_delete => :cascade, :name => "contact_form_fields_contact_form_id_fkey"

    add_foreign_key "content_copies", "nodes", :column => "copied_node_id", :on_delete => :cascade, :name => "content_copies_copied_node_id_fkey"

    add_foreign_key "forum_posts", "forum_threads", :on_delete => :cascade, :name => "forum_posts_forum_thread_id_fkey"

    add_foreign_key "forum_threads", "users", :on_delete => :cascade, :name => "forum_threads_user_id_fkey"
    add_foreign_key "forum_threads", "forum_topics", :on_delete => :cascade, :name => "forum_threads_forum_topic_id_fkey"

    add_foreign_key "forum_topics", "forums", :on_delete => :cascade, :name => "forum_topics_forum_id_fkey"

    add_foreign_key "interests_users", "interests", :on_delete => :cascade, :name => "interests_users_interest_id_fkey"
    add_foreign_key "interests_users", "users", :on_delete => :cascade, :name => "interests_users_user_id_fkey"

    add_foreign_key "links", "nodes", :column => "linked_node_id", :on_delete => :cascade, :name => "links_linked_node_id_fkey"

    add_foreign_key "news_items", "news_archives", :on_delete => :cascade, :name => "news_items_news_archive_id_fkey"

    add_foreign_key "newsletter_archives_users", "newsletter_archives",  :on_delete => :cascade, :name => "newsletter_archives_users_newsletter_archive_id_fkey"
    add_foreign_key "newsletter_archives_users", "users", :on_delete => :cascade, :name => "newsletter_archives_users_user_id_fkey"

    add_foreign_key "newsletter_edition_items", "newsletter_editions", :on_delete => :cascade, :name => "newsletter_edition_items_newsletter_edition_id_fkey"

    add_foreign_key "newsletter_edition_queues", "newsletter_editions", :on_delete => :cascade, :name => "newsletter_edition_queues_newsletter_edition_id_fkey"
    add_foreign_key "newsletter_edition_queues", "users", :on_delete => :cascade, :name => "newsletter_edition_queues_user_id_fkey"

    add_foreign_key "newsletter_editions", "newsletter_archives", :on_delete => :cascade, :name => "newsletter_editions_newsletter_archive_id_fkey"

    add_foreign_key "nodes", "nodes", :column => "parent_id", :on_delete => :cascade, :name => "nodes_parent_id_fkey"
    add_foreign_key "nodes", "templates",  :on_delete => :restrict, :name => "nodes_template_id_fkey"
    add_foreign_key "nodes", "users", :column => "edited_by", :on_delete => :set_null, :name => "nodes_edited_by_fkey"
    add_foreign_key "nodes", "categories", :name => "nodes_category_id_fkey"

    add_foreign_key "poll_options", "poll_questions", :on_delete => :cascade, :name => "poll_options_poll_question_id_fkey"

    add_foreign_key "poll_questions", "polls", :on_delete => :cascade, :name => "poll_questions_poll_id_fkey"

    add_foreign_key "role_assignments", "users", :on_delete => :cascade, :name => "role_assignments_user_id_fkey"
    add_foreign_key "role_assignments", "nodes", :on_delete => :cascade, :name => "role_assignments_node_id_fkey"

    add_foreign_key "sections", "nodes", :column => "frontpage_node_id", :on_delete => :set_null, :name => "sections_frontpage_node_id_fkey"

    add_foreign_key "side_box_elements", "nodes", :column => "parent_id", :on_delete => :cascade, :name => "side_box_elements_parent_id_fkey"
    add_foreign_key "side_box_elements", "nodes", :column => "content_id", :on_delete => :cascade, :name => "side_box_elements_content_id_fkey"

    add_foreign_key "weblog_posts", "weblogs", :on_delete => :cascade, :name => "weblog_posts_weblog_id_fkey"

    add_foreign_key "weblogs", "users", :on_delete => :cascade, :name => "weblogs_user_id_fkey"
    add_foreign_key "weblogs", "weblog_archives", :on_delete => :cascade, :name => "weblogs_weblog_archive_id_fkey"
  end

  def down
    drop_table "abbreviations"
    drop_table "agenda_item_categories"
    drop_table "agenda_items"
    drop_table "attachments"
    drop_table "calendar_items"
    drop_table "calendars"
    drop_table "categories"
    drop_table "combined_calendars"
    drop_table "comments"
    drop_table "contact_boxes"
    drop_table "contact_form_fields"
    drop_table "contact_forms"
    drop_table "content_copies"
    drop_table "db_files"
    drop_table "feeds"
    drop_table "forum_posts"
    drop_table "forum_threads"
    drop_table "forum_topics"
    drop_table "forums"
    drop_table "html_pages"
    drop_table "images"
    drop_table "interests"
    drop_table "interests_users", :id => false
    drop_table "links"
    drop_table "meeting_categories"
    drop_table "news_archives"
    drop_table "news_items"
    drop_table "newsletter_archives"
    drop_table "newsletter_archives_users", :id => false
    drop_table "newsletter_edition_items"
    drop_table "newsletter_edition_queues"
    drop_table "newsletter_editions"
    drop_table "nodes"
    drop_table "pages"
    drop_table "poll_options"
    drop_table "poll_questions"
    drop_table "polls"
    drop_table "role_assignments"
    drop_table "sections"
    drop_table "side_box_elements"
    drop_table "synonyms"
    drop_table "templates"
    drop_table "top_hits_pages"
    drop_table "users"
    drop_table "versions"
    drop_table "weblog_archives"
    drop_table "weblog_posts"
    drop_table "weblogs"
  end
end
