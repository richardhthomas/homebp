Homebp::Application.routes.draw do
  root :to => "static_pages#blood-pressure-treatment"
  
  get 'blood-pressure-treatment', to: 'landing_pages#blood-pressure-treatment'
  get 'find-out-more', to: 'landing_pages#find-out-more', as: 'find_out_more'
  
  get 'info/:id', to: 'info#show', as: 'info'
  
  get "static_pages/features"
  get "static_pages/about"
  get "static_pages/tac"
  #get "static_pages/measurement-of-blood-pressure", as: 'landing_page'
  
  resources :current_bps do
    collection do
      get 'signup_bp_migration'
      get 'create_average_bp'
    end
  end
  
  resources :messages
  
  devise_for :users, :controllers => {:registrations => "registrations"}
  
  namespace :account do
    get 'home'
    get 'router'
    get 'readings_due'
    get 'set_bp_entry_datetime'
    post 'is_bp_set_completable'
    get 'restart_needed'
    post 'restart'
    get 'submit_readings'
  end
  
  namespace :admin do
    get "menu", :controller => "admin"
    resources :users, :controller => "user_admin"
    resources :current_bps, :controller => "current_bps_admin"
    resources :average_bps, :controller => "average_bps_admin"
    resources :messages, :controller => "messages_admin" do
      member do
        get 'new_individual'
      end
      collection do
        post 'chase_user_for_bp'
      end
    end
    root :to => "admin#menu"
  end
  
  get '*rest', :to => 'static_pages#redirect'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

end
