Homebp::Application.routes.draw do
  get "static_pages/home"
  get "static_pages/about"
  get "static_pages/tac"
  get "static_pages/sign_in_msg"
  
  get "/blood_pressure_treatment" => 'current_bps#landing_page'  
  
  get "account/home"
  
  resources :current_bps do
    collection do
      #get 'display_bp'
      #post 'review'
      #patch 'update_bp'
      get 'new2'
      get 'signup_bp_migration'
      #get 'router'
      get 'create_average_bp'
      #get 'choosing_a_monitor'
      get 'how_to_measure_bp'
    end
  end
  
  resources :messages
  
  devise_for :users, :controllers => {:registrations => "registrations"}
  
  namespace :admin do
    get "menu", :controller => "admin"
    resources :users, :controller => "user_admin"
    resources :current_bps, :controller => "current_bps_admin"
    resources :average_bps, :controller => "average_bps_admin"
    resources :messages, :controller => "messages_admin" do
      member do
        get 'new_individual'
      end
    end
    root :to => "admin#menu"
  end
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
  
  root :to => "account#router"
  
end
