Rails.application.routes.draw do
  resource :session, only: [:new, :create, :destroy]

  resources :nodes do
    member do
      get :changes
    end

    resources :comments, only: [:create, :destroy]
  end

  get '/alphabetic_indices/:id/:letter' => 'alphabetic_indices#letter', as: :letter

  resource :sitemap, only: :show do
    collection do
      get :changes
    end
  end

  resources :agenda_items, only: :show
  resources :alphabetic_indices, only: :show
  resources :attachments, only: :show

  resources :calendars, only: [:index, :show] do
    member do
      get :tomorrow
    end
  end

  resources :carrousels, only: :show

  resources :combined_calendars do
    member do
      get :tomorrow
    end
  end

  resources :contact_boxes, only: :show

  resources :contact_forms, only: :show do
    member do
      post :send_message
    end
  end

  resources :events, only: :show do
    resources :event_registrations, only: [:create, :destroy]
  end

  resources :faqs,            only: :show
  resources :faq_archives,    only: :show
  resources :faq_suggestions, only: [:new, :create]

  resources :feeds, only: :show
  resources :forums, only: :show

  resources :forum_topics, only: :show do
    resources :forum_threads, except: :index do
      member do
        put :open
        put :close
      end

      resources :forum_posts, except: :index
    end
  end

  resources :html_pages, only: :show

  resources :images, only: :show do
    member do
      get :thumbnail
      get :sidebox
      get :full
      get :banner
      get :header
      get :big_header
      get :newsletter_banner
      get :private_thumbnail
      get :private_sidebox
      get :private_full
      get :private_banner
      get :private_header
    end
  end

  resources :links, only: :show
  resources :links_boxes, only: :show

  resources :newsletter_archives, only: :show do
    member do
      post :subscribe
      match :unsubscribe, via: [:get, :delete]
    end
  end

  resources :newsletter_editions, only: :show
  resources :news_archives, only: :show do
    member do
      get ':year/:month' => :archive, year: /\d{4}/, month: /\d{1,2}/
      get :archive
    end
  end
  resources :news_items, only: :show
  resources :news_viewers, only: :show do
    member do
      get ':year/:month' => :archive, year: /\d{4}/, month: /\d{1,2}/
      get :archive
    end
  end
  resources :pages, only: :show
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :polls, only: :show

  resources :poll_questions, only: :show do
    member do
      put :vote
      get :results
    end
  end

  resources :search_pages, only: :show
  resources :sections, only: :show
  resources :shares, only: [:new, :create]
  resources :social_media_links_boxes, only: :show
  resources :themes, only: :show do
    get   'suggestie' => 'faq_suggestions#new'
    post  'suggestie' => 'faq_suggestions#create'
  end
  resources :top_hits_pages, only: :show

  resources :users, except: :index do
    member do
      get :send_verification_email
      get :verification
      get :profile
      get :confirm_destroy
    end
  end

  resources :weblogs, except: :index

  resources :weblog_archives, only: :show do
    resources :weblogs, except: :index do
      resources :weblog_posts, except: :index do
        member do
          get :confirm_destroy
          delete :destroy_image
        end
      end

      member do
        get :confirm_destroy
      end
    end
  end

  resources :weblog_posts, except: :index

  # =============== ADMIN NAMESPACE ===============

  namespace :admin do
    resources :abbreviations, except: [:show, :edit]

    resources :agenda_items, except: [:index, :destroy] do
      member do
        get :previous
      end
    end

    resources :alphabetic_indices, except: [:index, :destroy]

    resources :attachments, except: [:index, :destroy] do
      member do
        get :previous
        get :preview
      end
    end

    resources :attachment_themes, except: :index, controller: 'themes', defaults: { type: 'attachment_theme' }

    resources :calendars, except: :destroy

    resources :calendar_items, except: :index do
      member do
        get :previous
      end
    end

    resources :carrousels, except: [:index, :destroy]

    resources :combined_calendars, except: [:index, :destroy]
    resources :comments, only: [:index, :update, :destroy]
    resources :contact_boxes, except: [:index, :destroy]

    resources :contact_forms do
      resources :contact_form_fields

      resources :responses, only: [:index, :update, :destroy] do
        member do
          get :upload_csv
          post :import_csv
        end

        resources :response_fields, only: [] do
          member do
            get :file
          end
        end
      end
    end

    resources :content_copies, only: [:show, :create] do
      member do
        get :previous
      end
    end

    resources :data_warnings, only: [:index, :destroy] do
      collection do
        delete :clear
      end
    end

    resources :external_links, except: [:index, :destroy], controller: 'links', defaults: { type: 'external_link' } do
      member do
        get :previous
      end
    end

    resources :faqs,           except: [:destroy, :index]
    resources :faq_archives,   except: [:destroy, :index]
    resources :faq_categories, except: :index, controller: 'themes', defaults: { type: 'faq_category' }
    resources :faq_themes,     except: :index, controller: 'themes', defaults: { type: 'faq_theme' }
    resources :faq_top_fives,  except: :index, controller: 'themes', defaults: { type: 'faq_top_five' }

    resources :feeds,        except: [:index, :destroy]
    resources :forums,       except: [:index, :destroy]
    resources :forum_topics, except: [:index, :destroy]
    resources :html_pages,   except: [:index, :destroy]

    resources :images, except: [:index, :destroy] do
      member do
        get :previous
        get :preview
        get :thumbnail
        get :thumbnail_preview
        get :banner_preview
      end
    end

    resources :internal_links, except: [:index, :destroy], controller: 'links', defaults: { type: 'internal_link' } do
      member do
        get :previous
      end
    end

    resources :links_boxes, except: [:index, :destroy]

    resources :meetings, except: :index do
      member do
        get :previous
      end
    end

    resources :newsletter_archives, except: :destroy

    resources :newsletter_editions, except: [:index, :destroy] do
      member do
        get :previous
      end
    end

    resources :newsletter_subscriptions, only: [:show, :destroy] do
      collection do
        get :list
      end

      resources :users, only: [:show, :destroy]
    end

    resources :news_archives, except: :destroy

    resources :news_items, except: [:index, :destroy] do
      member do
        get :previous
      end
    end

    resources :news_viewers, except: [:index, :destroy] do
      member do
        get :edit_items
      end

      resources :news_viewer_items, only: [:index, :create] do
        collection do
          match :available_news_items, via: [:get, :post]
          delete :delete_news_item
          put :update_positions
        end
      end

      resources :news_viewer_archives, only: [:create] do
        collection do
          delete :delete_news_archive
        end
      end
    end

    resources :pages, except: [:index, :destroy] do
      member do
        get :previous
      end
    end

    resources :polls, except: [:index, :destroy]
    resources :poll_questions, except: [:index, :destroy]
    resources :role_assignments, only: [:index, :new, :create, :destroy]
    resources :search_pages, except: [:index, :destroy]

    resources :sections, except: [:index, :destroy] do
      member do
        get :previous
        get :send_expiration_notifications
        get :import
        post :build
      end
    end

    resources :settings, only: [:index, :update]
    resources :sites, except: [:index, :destroy]
    resources :social_media_links_boxes, except: [:index, :destroy]
    resources :synonyms, only: [:index, :create, :update, :destroy]
    resources :link_themes, except: :index, controller: 'themes', defaults: { type: 'link_theme' }
    resources :top_hits_pages, except: [:index, :destroy]
    resources :tags, only: [:index, :update, :destroy]

    resources :trash, only: [:index] do
      collection do
        delete :clear
      end

      member do
        put :restore
      end
    end

    resources :url_aliases, only: [:index, :create, :update, :destroy]

    resources :users do
      collection do
        post :invite
        get :privileged
        get :last_sign_ins
      end

      member do
        get :accessible_newsletter_archives
        get :interests
        post :switch_user_type
        post :revoke
      end
    end

    resources :versions, only: :index do
      member do
        put :approve
        put :reject
      end
    end

    resources :weblogs, only: [:index, :show, :edit, :update]
    resources :weblog_archives, except: :destroy
    resources :weblog_posts, only: [:show, :edit, :update]

    resources :nodes, only: [:index, :edit, :update, :destroy] do
      collection do
        get :bulk_edit
        put :bulk_update
      end

      member do
        put :set_visibility
        put :set_accessibility
        put :move
        put :make_global_frontpage
        get :audit_show
        get :audit_edit
        get :count_children
        put :sort_children
        get :previous_diffed
        get :export_newsletter
        put :move_by_date
      end

      resource :layout, only: [:edit, :update]

      resources :layouts, only: [] do
        collection do
          post :variants_settings_and_targets, constraints: { id: /.+/ }
        end

        member do
          get :targets
        end
      end
    end

    match 'nodes/:parent_id/:year/:month' => 'nodes#bulk_destroy', year: /\d{4}/, month: /\d{1,2}/, parent_id: /\d+/, via: :all
    match 'nodes/:parent_id/:year' => 'nodes#bulk_destroy', year: /\d{4}/, parent_id: /\d+/, via: :all

    match 'final_editor' => 'versions#index', via: :all
    match 'versions.:format' => 'versions#index', via: :post

    root to: 'nodes#index'
  end

  root to: 'pages#home'

  # =============== CUSTOM ROUTES ===============

  get '/attachments/:id/:basename' => 'attachments#show'
  get '/attachments/:action/:id/:basename' => 'attachments#index'
  get '/attachments/:id/:basename.:format' => 'attachments#show', as: :download
  match '/login' => 'sessions#new', as: :login, via: :all
  match '/logout' => 'sessions#destroy', as: :logout, via: :all
  get '/signup' => 'users#new', as: :signup

  if Devcms.search_configuration[:enabled_search_engines].present?
    get '/search(/:search_engine)' => 'search#index', as: :search
  end

  get '/profile' => 'users#profile', as: :profile
  get '/synonyms.txt' => 'application#synonyms', as: :synonyms, format: :txt

  match '/404', to: 'application#handle_404', via: :all
  match '/500', to: 'application#handle_500', via: :all
end
