Graf::Application.routes.draw do  resources :github_loads
  resources :companies
  resources :users
  resources :pull_requests
  resources :repos
  resources :github_loads
  resources :github_load_msgs
  resources :commits

  get '/dashboard', to: 'dashboard#index'
  get '/api' => 'api#index'

  # Load Paths
  get '/load', to: 'load#index'
  get '/start_load', to: 'load#start_load'
  get '/load_status', to: 'load#load_status'
  get '/delete_load_history', to: 'load#delete_load_history'
  get '/delete_all_data', to: 'load#delete_all_data'

  # Info Paths
  get '/info', to: 'info#info'

  # Main Page Paths
  get '/analytics', to: 'dashboard#index'
  get '/data_viewer', to: 'data_viewer#index'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root :to => 'dashboard#index'

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
