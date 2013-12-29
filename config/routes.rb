Homebp::Application.routes.draw do
  root :to => "account#router"
  
  #get "/blood_pressure_treatment" => 'info/info#home_page'
  
  namespace :info, :controller => "info" do
    get 'home_page'
    get 'what_is_blood_pressure'
    get 'measuring_blood_pressure'
    get 'treating_blood_pressure'
    
    scope '/measuring', :controller => "info" do
      get 'how_do_i_measure_my_blood_pressure'
      get 'when_should_i_measure_my_blood_pressure'
      get 'how_do_i_choose_a_blood_pressure_machine'
    end
    
    scope '/what', :controller => "info" do
      get 'what_am_i_measuring'
      get 'what_do_the_numbers_mean'
      get 'what_is_the_normal_range_for_me'
    end
    
    scope '/treatment', :controller => "info" do
      get 'lifestyle_options'
      get 'complementary_therapy'
      get 'medication'
      
      scope '/lifestyle', :controller => "info" do
        get 'diet'
        get 'exercise'
        get 'smoking'
      end
      
      scope '/complementary', :controller => "info" do
        get 'supplements'
        get 'acupuncture'
        get 'herbal'
      end
      
      scope '/medication', :controller => "info" do
        get 'when_is_medication_recommended'
        get 'why_do_i_need_to_take_more_than_one_medication'
        get 'how_can_i_reduce_the_risk_of_side_effects'
        get 'what_are_the_different_medication_options_for_me'
        
        scope '/options', :controller => "info" do
          get 'calcium_channel_blockers'
          get 'ace_inhibitors'
          get 'diuretics'
          get 'a2rbs'
          get 'beta_blockers'
        end
      end
    end
  end
    
  get "static_pages/features"
  get "static_pages/about"
  get "static_pages/tac"
  get "static_pages/meds_id_wizard"
  
  resources :current_bps do
    collection do
      #post 'review'
      #patch 'update_bp'
      get 'signup_bp_migration'
      get 'create_average_bp'
      get 'how_to_measure_bp'
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
