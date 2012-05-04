ActionController::Routing::Routes.draw do |map|
  map.resource  :session, :only => [ :new, :create, :destroy ], :collection => { :destroy => :any }

  map.resources :nodes, :member => { :changes => :get, :all_changes => :get }  do |node|
    node.resources :comments, :only => [ :create, :destroy ], :member => { :destroy => :any }
  end

  map.letter    '/alphabetic_indices/:id/:letter.:format', :controller => :alphabetic_indices, :action => :letter
  map.resource  :sitemap,             :only => :show, :collection => { :changes => :get }
  map.resources :agenda_items,        :only => :show
  map.resources :alphabetic_indices,  :only => :show
  map.resources :attachments,         :only => :show
  map.resources :calendars,           :only => [ :index, :show ], :member => { :tomorrow => :get }
  map.resources :combined_calendars,                              :member => { :tomorrow => :get }
  map.resources :contact_boxes,       :only => :show
  map.resources :contact_forms,       :only => :show,             :member => { :send_message => :post }
  map.resources :events,              :only => :show do |event|
    event.resources :event_registrations, :only => [ :create, :destroy ]
  end
  map.resources :feeds,               :only => :show
  map.resources :forums,              :only => :show
  map.resources :forum_topics,        :only => :show do |forum_topic|
    forum_topic.resources :forum_threads,   :except => :index,    :member => { :open => :put, :close => :put } do |forum_thread|
      forum_thread.resources :forum_posts, :except => :index
    end
  end
  map.resources :html_pages,          :only => :show
  map.resources :images,              :only => :show,             :member => { :thumbnail => :get, :sidebox => :get, :full => :get, :content_box_header => :get, :header => :get, :big_header => :get, :private_thumbnail => :get, :private_sidebox => :get, :private_full => :get, :private_content_box_header => :get, :private_header => :get }
  map.resources :links,               :only => :show
  map.resources :links_boxes,         :only => :show
  map.resources :newsletter_archives, :only => :show,             :member => { :subscribe => :post, :unsubscribe => :any }
  map.resources :newsletter_editions, :only => :show
  map.resources :news_archives,       :only => :show
  map.resources :news_items,          :only => :show
  map.resources :news_viewers,        :only => :show
  map.resources :pages,               :only => :show
  map.resources :password_resets,     :only => [:new, :create, :edit, :update]
  map.resources :polls,               :only => :show
  map.resources :poll_questions,      :only => :show,             :member => { :vote => :put, :results => :get }
  map.resources :sections,            :only => :show
  map.resources :shares,              :only => [ :new, :create ]
  map.resources :social_media_links_boxes, :only => :show
  map.resources :themes, :only => :show
  map.resources :top_hits_pages, :only => :show
  map.resources :users, :except => :index, :member => { :send_verification_email => :get, :verification => :get, :profile => :get, :confirm_destroy => :get }
  map.resources :weblogs, :except => :index, :member => { :destroy => :any } # JS fallback; See ApplicationController for more info.
  map.resources :weblog_archives, :only => :show do |weblog_archive|
    weblog_archive.resources :weblogs, :except => :index, :member => { :destroy => :any } do |weblog|
      weblog.resources :weblog_posts, :except => :index, :member => { :destroy => :any }
    end
  end
  map.resources :weblog_posts, :except => :index

  map.namespace(:admin) do |admin|
    admin.resources :abbreviations, :except => [ :show, :edit ]
    admin.resources :agenda_items, :except => [ :index, :destroy ], :member => { :previous => :get }
    admin.resources :alphabetic_indices, :except => [ :index, :destroy ]

    admin.resources :attachments, :except => [ :index, :destroy ], :member => { :previous => :get, :preview => :get }, :collection => { :categories => :any }
    admin.resources :attachment_themes,   :except => :index,  :controller => :themes, :requirements => { :type => :attachment_theme }
    admin.resources :calendars, :except => :destroy
    admin.resources :calendar_items, :except => :index, :member => { :previous => :get }
    admin.resources :carrousels, :except => [ :index, :destroy ]

    admin.resources :categories,
                      :only => [ :index, :create, :update, :destroy ],
                      :collection => { :categories => :get, :root_categories => :get },
                      :member => { :add_to_favorites => :put, :remove_from_favorites => :put, :category_options => :get, :synonyms => :get }
    admin.resources :combined_calendars, :except => [ :index, :destroy ]
    admin.resources :comments, :only => [ :index, :update, :destroy ]
    admin.resources :contact_boxes, :except => [ :index, :destroy ]
    
    admin.resources :contact_forms do |contact_form|
      contact_form.resources :contact_form_fields
      contact_form.resources :responses, :only => [ :index, :update, :destroy ], :member => { :import_csv => :any, :upload_csv => :any } do |response|
        response.resources :response_fields, :only => [], :member => { :file => :get }
      end
    end
    
    admin.resources :content_copies, :only => [ :show, :create ], :member => { :previous => :get }
    admin.resources :feeds, :except => [ :index, :destroy ]
    admin.resources :forums, :except => [ :index, :destroy ]
    admin.resources :forum_topics, :except => [ :index, :destroy ]
    admin.resources :html_pages, :except => [ :index, :destroy ]
    admin.resources :images, :except => [ :index, :destroy ], :member => { :previous => :get, :preview => :get, :thumbnail => :get, :thumbnail_preview => :get, :content_box_header_preview => :get }
    admin.resources :links, :except => [ :index, :destroy ], :member => { :previous => :get }
    admin.resources :links_boxes, :except => [ :index, :destroy ]
    admin.resources :meetings, :except => :index, :member => { :previous => :get }
    admin.resources :newsletter_archives, :except => :destroy
    admin.resources :newsletter_editions, :except => [ :index, :destroy ], :member => { :previous => :get }
    admin.resources :newsletter_subscriptions, :only => [ :show, :destroy ], :member => { :subscriptions => :any } do |admin_newsletter_subscriptions|
      admin_newsletter_subscriptions.resources :users, :only => [ :show, :destroy ], :controller => 'newsletter_subscriptions'
    end
    admin.resources :news_archives, :except => :destroy
    admin.resources :news_items, :except => [ :index, :destroy ], :member => { :previous => :get }
    admin.resources :news_viewers, :except => [ :index, :destroy ], :member => { :edit_items => :get } do |admin_news_viewers| 
      admin_news_viewers.resources :news_viewer_items, :only => [:index, :create], :collection => { :available_news_items => :any, :delete_news_item => :delete, :update_positions => :put }
      admin_news_viewers.resources :news_viewer_archives, :only => [:create], :collection => { :delete_news_archive => :delete }
    end
    admin.resources :pages, :except => [ :index, :destroy ], :member => { :previous => :get }
    admin.resources :polls, :except => [ :index, :destroy ]
    admin.resources :poll_questions, :except => [ :index, :destroy ]
    admin.resources :role_assignments, :only => [ :index, :new, :create, :destroy ]
    admin.resources :search_pages, :except => [ :index, :destroy ]
    admin.resources :sections, :except => [ :index, :destroy ], :member => { :previous => :get, :send_expiration_notifications => :any, :import => :get, :build => :post }
    admin.resources :settings, :only => [ :index, :update ]
    admin.resources :sites, :except => [ :index, :destroy ]
    admin.resources :social_media_links_boxes, :except => [ :index, :destroy ]
    admin.resources :synonyms, :only => [ :index, :create, :update, :destroy ]
    admin.resources :link_themes,   :except => :index,  :controller => :themes, :requirements => { :type => :link_theme }
    admin.resources :top_hits_pages, :except => [ :index, :destroy ]
    admin.resources :users, :member => { :accessible_newsletter_archives => :get, :interests => :get, :switch_user_type => :post, :revoke => :post }, :collection => { :invite => :post, :privileged => :get }
    admin.resources :versions, :only => :index, :member => { :approve => :put, :reject => :put }
    admin.resources :weblogs, :only => [ :index, :show, :edit, :update ]
    admin.resources :weblog_archives, :except => :destroy
    admin.resources :weblog_posts, :only => [ :show, :edit, :update ]
    
    admin.resources :nodes, :only => [ :index, :update, :destroy ],
                            :member => {
                              :set_visibility => :put,
                              :set_accessibility => :put,
                              :move => :put,
                              :make_global_frontpage => :put,
                              :audit_show => :get,
                              :audit_edit => :get,
                              :count_children => :get,
                              :sort_children => :put,
                              :previous_diffed => :get,
                              :export_newsletter => :get
                            },
                            :collection => {
                              :bulk_edit => :get,
                              :bulk_update => :put
                            } do |nodes|
      nodes.resource :layout, :only => [:edit, :update]
      nodes.resources :layouts, :only => [], :member => { :settings_variants_and_targets => :get,  :targets => :get }
    end    

    admin.connect 'nodes/:parent_id/:year/:month',
                  :controller => :nodes,
                  :action     => :bulk_destroy,
                  :year       => /\d{4}/,
                  :month      => /\d{1,2}/,
                  :parent_id  => /\d+/
    admin.connect 'nodes/:parent_id/:year',
                  :controller => :nodes,
                  :action     => :bulk_destroy,
                  :year       => /\d{4}/,
                  :parent_id  => /\d+/
  end

  map.connect '/admin', :controller => 'admin/nodes'
  map.connect '/admin/final_editor', :controller => 'admin/versions'
  map.connect '/admin/versions.:format', :controller => 'admin/versions', :action => :index, :conditions => { :method => :post }

  map.connect '/attachments/:id/:basename', :controller => 'attachments', :action => 'show'
  map.connect '/attachments/:action/:id/:basename', :controller => 'attachments'
  map.download '/attachments/:id/:basename.:format', :controller => 'attachments', :action => 'show'

  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.search_projects '/search/projects', :controller => 'search', :action => 'projects'
  map.search '/search/:search_engine', :controller => 'search', :action => 'index', :search_engine => ''
  map.profile '/profile', :controller => 'users', :action => 'profile'
  map.synonyms '/synonyms.txt', :controller => :application, :action => :synonyms, :format => :txt
  
  # Dynamic root route
  map.root :controller => '_delegated_root', :action => 'show'

  # Delegation route, should be defined after the more specific routes
  map.connect '/content/:id.:format', :controller => '_delegated', :action => 'show'
  map.delegated '/content/:id/:action', :controller => '_delegated', :action => 'show'
  
  # Default routes
  map.connect '/:controller/:action'
  map.connect '/:controller/:action/:id'
  map.connect '/:controller/:action/:id.:format'

  # URL aliasing route, should be defined last. Case-insensitive regexp using //i does not work!
  # Sync ID requirements to node.rb!
  map.connect '/:id.:format', :controller => '_aliased', :action => 'show', :requirements => { :id => /[a-zA-Z0-9_\-]((\/)?[a-zA-Z0-9_\-])*/ }
  map.aliased '/:id/:action', :controller => '_aliased', :action => 'show', :requirements => { :id => /[a-zA-Z0-9_\-]((\/)?[a-zA-Z0-9_\-])*/ }
  
end