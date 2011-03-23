ActionController::Routing::Routes.draw do |map|

  map.resource :session, :only => [ :new, :create, :destroy ]

  map.resources :nodes, :member => { :changes => :get, :all_changes => :get }  do |node|
    node.resources :comments, :only => [ :create, :destroy ], :member => { :destroy => :any }
  end

  map.resource :sitemap, :only => :show, :collection => { :changes => :get }
  map.resources :attachments, :only => :show
  map.resources :links, :only => :show
  map.resources :news_archives, :only => :show
  map.resources :news_items, :only => :show
  map.resources :newsletter_archives, :only => :show, :member => { :subscribe => :post, :unsubscribe => :any }
  map.resources :newsletter_editions, :only => :show
  map.resources :calendars, :only => [ :index, :show ], :member => { :tomorrow => :get }
  map.resources :combined_calendars, :member => { :tomorrow => :get }
  map.resources :events, :only => :show
  map.resources :contact_forms, :member => { :send_message => :post, :import_csv => :post, :upload_csv => :get, :export_csv => :get }
  map.resources :top_hits_pages, :only => :show
  map.resources :html_pages, :only => :show
  map.resources :pages, :only => :show
  map.resources :contact_boxes, :only => :show
  map.resources :sections, :only => :show
  map.resources :polls, :only => :show
  map.resources :poll_questions, :only => :show, :member => { :vote => :put, :results => :get }
  map.resources :users, :except => [ :index, :destroy ], :member => { :send_verification_email => :get, :verification => :get, :profile => :get }, :collection => { :send_password => :put, :request_password => :get }
  map.resources :images, :only => :show, :member => { :thumbnail => :get, :sidebox => :get, :full => :get, :content_box_header => :get, :header => :get, :private_thumbnail => :get, :private_sidebox => :get, :private_full => :get, :private_content_box_header => :get, :private_header => :get }
  map.resources :weblog_posts, :except => :index
  map.resources :weblogs, :except => :index, :member => { :destroy => :any } # JS fallback; See ApplicationController for more info.
  map.resources :news_viewers, :only => :show

  map.resources :shares, :only => [ :new, :create ]

  map.resources :weblog_archives, :only => :show do |weblog_archive|
    weblog_archive.resources :weblogs, :except => :index, :member => { :destroy => :any } do |weblog|
      weblog.resources :weblog_posts, :except => :index, :member => { :destroy => :any }
    end
  end

  map.resources :feeds, :only => :show

  map.resources :forums, :only => :show

  map.resources :forum_topics, :only => :show do |forum_topic|
    forum_topic.resources :forum_threads, :except => :index, :member => { :open => :put, :close => :put } do |forum_thread|
      forum_thread.resources :forum_posts, :except => :index
    end
  end

  map.resources :agenda_items, :only => :show

  map.resources :alphabetic_indices, :only => :show
  map.letter '/alphabetic_indices/:id/:letter.:format', :controller => :alphabetic_indices, :action => :letter

  map.resources :social_media_links_boxes, :only => :show

  map.namespace(:admin) do |admin|
    admin.resources :alphabetic_indices, :except => [ :index, :destroy ]
    admin.resources :attachments, :except => [ :index, :destroy ], :member => { :previous => :get, :preview => :get }, :collection => { :ajax => :any }
    admin.resources :social_media_links_boxes, :except => [ :index, :destroy ]
    admin.resources :approvals, :only => [ :index, :create ], :member => { :approve => :put, :reject => :put }
    admin.resources :permissions, :only => [ :index, :new, :create, :destroy ]
    admin.resources :categories,
                    :only => [ :index, :create, :update, :destroy ],
                    :collection => { :categories => :get, :root_categories => :get },
                    :member => { :add_to_favorites => :put, :remove_from_favorites => :put, :category_options => :get, :synonyms => :get }
    admin.resources :comments, :only => [ :index, :update, :destroy ]
    admin.resources :users, :member => { :accessible_newsletter_archives => :get, :interests => :get }, :collection => { :invite => :post }
    admin.resources :nodes, :only => [ :index, :update, :destroy ],
                            :member => {
                              :move => :put,
                              :make_global_frontpage => :put,
                              :audit_show => :get,
                              :audit_edit => :get,
                              :count_children => :get,
                              :sort_children => :put,
                              :previous_diffed => :get
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
    
    admin.resources :html_pages, :except => [ :index, :destroy ]
    admin.resources :top_hits_pages, :except => [ :index, :destroy ]
    admin.resources :pages, :except => [ :index, :destroy ], :member => { :previous => :get }
    admin.resources :contact_boxes, :except => [ :index, :destroy ]
    admin.resources :sections, :except => [ :index, :destroy ], :member => { :previous => :get }
    admin.resources :sites, :except => [ :index, :destroy ], :member => { :previous => :get }
    admin.resources :news_archives, :except => :destroy
    admin.resources :news_items, :except => [ :index, :destroy ], :member => { :previous => :get }
    admin.resources :calendars, :except => :destroy
    admin.resources :combined_calendars, :except => [ :index, :destroy ]
    admin.resources :calendar_items, :except => :index, :member => { :previous => :get }
    admin.resources :meetings, :except => :index, :member => { :previous => :get }
    admin.resources :contact_forms do |contact_form|
      contact_form.resources :contact_form_fields
      contact_form.resources :responses, :only => [ :index, :update, :destroy ]
    end
    admin.resources :links, :except => [ :index, :destroy ], :member => { :previous => :get }
    admin.resources :images, :except => [ :index, :destroy ], :member => { :previous => :get, :preview => :get, :thumbnail => :get, :thumbnail_preview => :get, :content_box_header_preview => :get }
    admin.resources :newsletter_archives, :except => :destroy
    admin.resources :newsletter_editions, :except => [ :index, :destroy ], :member => { :previous => :get }
    admin.resources :newsletter_subscriptions, :only => [ :show, :destroy ], :member => { :subscriptions => :any } do |admin_newsletter_subscriptions|
      admin_newsletter_subscriptions.resources :users, :only => [ :show, :destroy ], :controller => 'newsletter_subscriptions'
    end
    admin.resources :polls, :except => [ :index, :destroy ]
    admin.resources :poll_questions, :except => [ :index, :destroy ]
    admin.resources :weblog_archives, :except => :destroy
    admin.resources :weblogs, :only => [ :index, :show, :edit, :update ]
    admin.resources :weblog_posts, :only => [ :show, :edit, :update ]
    admin.resources :feeds, :except => [ :index, :destroy ]
    admin.resources :forums, :except => [ :index, :destroy ]
    admin.resources :forum_topics, :except => [ :index, :destroy ]
    admin.resources :agenda_items, :except => [ :index, :destroy ], :member => { :previous => :get }
    admin.resources :content_copies, :only => [ :show, :create ], :member => { :previous => :get }
    admin.resources :synonyms, :only => [ :index, :create, :update, :destroy ]
    admin.resources :abbreviations, :except => [ :show, :edit ]
    admin.resources :search_pages, :except => [ :index, :destroy ]
    admin.resources :news_viewers, :except => [ :index, :destroy ], :member => { :edit_items => :get } do |admin_news_viewers| 
      admin_news_viewers.resources :news_viewer_items, :only => [:index, :create], :collection => { :available_news_items => :any, :delete_news_item => :delete, :update_positions => :put }
      admin_news_viewers.resources :news_viewer_archives, :only => [:create], :collection => { :delete_news_archive => :delete }
    end
    admin.resources :carrousels, :except => [ :index, :destroy ]
    admin.resources :settings, :only => [ :index, :update ]
  end

  map.connect '/admin', :controller => 'admin/nodes'
  map.connect '/admin/final_editor', :controller => 'admin/approvals'

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
end