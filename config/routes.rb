Snorby::Application.routes.draw do
  resources :lookups

  # This feature is not ready yet
  # resources :notifications

  resources :jobs do
    member do
      get :last_error
      get :handler
    end
  end

  resources :classifications

  devise_for :users, path_names: { sign_in: 'login',
                                   sign_out: 'logout',
                                   sign_up: 'register' },
                     controllers: { registrations: 'registrations',
                                    sessions: 'sessions',
                                    passwords: 'passwords' } do
    get '/login' => 'devise/sessions#new'
    delete '/logout', to: 'devise/sessions#destroy'
    get '/reset/password', to: 'devise/passwords#edit'
  end

  root to: 'page#dashboard'

  resources :sensors do
    collection do
      get :agent_list
      post :update_name
    end
  end

  resources :settings do
    collection do
      get :restart_worker
      get :start_sensor_cache
      get :start_daily_cache
      get :start_geoip_update
      get :start_worker
    end
  end

  resources :signatures do
    collection do
      get :search
    end
  end

  resources :severities

  get '/dashboard', controller: 'page', action: 'dashboard'
  get '/search', controller: 'page', action: 'search'
  match '/results', controller: 'page', action: 'results', via: [:get, :post]
  get '/force/cache', controller: 'page', action: 'force_cache'
  get '/cache/status', controller: 'page', action: 'cache_status'
  get '/search/json', controller: 'page', action: 'search_json'

  resources :saved_searches, path: '/saved/searches' do
    collection do
      post :title
      put :update
    end

    member do
      get :view
      put :update
    end
  end

  get ':controller(/:action(/:sid/:cid))', controller: 'events'

  resources :asset_names do
    member do
      delete :remove
    end

    collection do
      post :add
      post :bulk_upload
      get 'new_bulk_upload', action: :new_bulk_upload, as: 'new_bulk_upload'
    end
  end

  resources :events do
    resources :notes

    collection do
      get :sessions
      get :view
      get :create_mass_action
      post :mass_action
      get :create_email
      post :email
      get :hotkey
      post :export
      get :lookup
      get :rule
      get :packet_capture
      get :history
      post :classify
      post :classify_sessions
      post :mass_update
      get :queue
      post :favorite
      get :last
      get :since
      get :activity
      post :request_packet_capture
    end
  end

  resources :notes

  resources :users do
    collection do
      post :toggle_settings
      post :remove
      post :add
    end
  end

  resources :page
end
