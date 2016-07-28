Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  resources :users
  resources :batches
  resources :products
  get '/products/:id/:slug' => 'products#slug_show'
  resources :milestones
  resources :commits
  resources :product_items

  # TODO: move these to API methods
  # get '/batches/:id/complete_batch' => 'batches#complete_batch'
  # get '/batches/:id/cancel_batch' => 'batches#cancel_batch'
  # post '/batches/:id/cancel_batch' => 'batches#cancel_batch'
  # get '/batches/:id/grant_discount' => 'batches#grant_discount'
  # get '/batches/:id/mark_batch_as_past' => 'batches#mark_batch_as_past'

  # API Methods:
  get '/api/grant_discount' => 'api#grant_discount'
  get '/api/expire_product' => 'api#expire_product'
  get '/api/create_credit_card/:token' => 'api#create_credit_card'
  get '/api/charge_credit_card' => 'api#charge_credit_card'
  get '/api/create_stripe_connect/:scope/:code' => 'api#create_stripe_connect'
  get '/api/send_money' => 'api#send_money'
  get '/api/create_shipping_address' => 'api#create_shipping_address'
  post '/api/create_shipping_address' => 'api#create_shipping_address'
  get '/api/save_shipping_id/:address_id' => 'api#save_shipping_id'
  post '/api/save_shipping_id/:address_id' => 'api#save_shipping_id'
  get '/api/ship_batch' => 'api#ship_batch'
  post '/api/ship_batch' => 'api#ship_batch'
  get '/api/save_shipment' => 'api#save_shipment'
  post '/api/save_shipment' => 'api#save_shipment'
  get '/api/get_shipping_label' => 'api#get_shipping_label'
  post '/api/get_shipping_label' => 'api#get_shipping_label'
  get '/api/create_shipment' => 'api#create_shipment'
  post '/api/create_shipment' => 'api#create_shipment'
  get '/api/purchase_shipment' => 'api#purchase_shipment'
  post '/api/purchase_shipment' => 'api#purchase_shipment'
  get '/api/prawn_test' => 'api#prawn_test'
  post '/api/prawn_test' => 'api#prawn_test'
  get '/api/create_tracking' => 'api#create_tracking'
  post '/api/create_tracking' => 'api#create_tracking'

  get '/api/shipping/create_tracking' => 'api/shipping#create_tracking'
  post '/api/shipping/create_tracking' => 'api/shipping#create_tracking'

  get '/about' => 'welcome#about'
  get '/faq' => 'welcome#faq'
  get '/landing' => 'welcome#landing'

  get '/wholesaler' => 'wholesalers#index', as: :wholesaler
  get '/wholesaler_signup' => 'wholesalers#signup'
  get '/wholesaler/accounts' => 'wholesalers#accounts', as: :wholesaler_accounts
  get '/new_product' => 'wholesalers#new_product'
  get '/past_products' => 'wholesalers#past_products'
  get '/manage_shipping' => 'wholesalers#manage_shipping'
  get '/analytics' => 'wholesalers#analytics'
  get '/needs_attention' => 'wholesalers#needs_attention'
  # get '/past-batches' => 'wholesalers#past_batches', as: :past_batches
  # get '/ship_batch/:id' => 'wholesalers#ship_batch', as: :ship_batch
  get '/account_verify' => 'users#accounts_verify', as: :accounts_verify
  get '/needs_shipping' => 'wholesalers#needs_shipping', as: :needs_shipping
  get '/needs_shipping/:product_id' => 'wholesalers#show_needs_shipping'

  get '/retailer' => 'retailers#index', as: :retailer
  get '/retailer_signup' => 'retailers#signup'
  get 'retailers/accounts' => 'retailers#accounts', as: :retailer_accounts
  get 'retailer/order_history' => 'retailers#order_history', as: :retailer_order_history

  get '/shop' => 'welcome#shop', as: :shop

  post '/sessions' => 'sessions#create'
  delete '/sessions' => 'sessions#destroy'

  root 'users#index'

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
