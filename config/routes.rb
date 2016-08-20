Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get '/api/stripe_connect_charge' => 'api#stripe_connect_charge'
  post '/api/stripe_connect_charge' => 'api#stripe_connect_charge'

  resources :users
  put 'users/password_reset/:id' => 'users#password_reset'
  resources :products
  resources :commits
  resources :wholesalers
  resources :retailers
  resources :companies

                  #///////////////////#
                  #     API ROUTES    #
                  #///////////////////#

  get '/api/products/:action' => 'api/products'
  post '/api/products/:action' => 'api/products'

  get '/api/payments/:action' => 'api/payments'
  post '/api/payments/:action' => 'api/payments'

  get '/api/wholesalers/:action' => 'api/wholesalers'
  post '/api/wholesalers/:action' => 'api/wholesalers'

  get '/api/shipping/:action' => 'api/shipping'
  post '/api/shipping/:action' => 'api/shipping'

  get '/api/send_password_reset' => 'api#send_password_reset'
  post '/api/send_password_reset' => 'api#send_password_reset'

  get '/api/grant_discount' => 'api#grant_discount'
  get '/api/expire_product' => 'api#expire_product'

  get '/api/make_purchase_order' => 'api#make_purchase_order'
  post '/api/make_purchase_order' => 'api#make_purchase_order'

  get '/api/create_credit_card/:token' => 'api#create_credit_card'
  post '/api/create_credit_card/:token' => 'api#create_credit_card'
  get '/api/charge_credit_card' => 'api#charge_credit_card'
  get '/api/create_stripe_connect/:scope/:code' => 'api#create_stripe_connect'
  get '/api/send_money' => 'api#send_money'
  get '/api/delete_credit_card' => 'api#delete_credit_card'
  post '/api/delete_credit_card' => 'api#delete_credit_card'

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
  get '/api/create_tracking_and_charge' => 'api#create_tracking_and_charge'
  post '/api/create_tracking_and_charge' => 'api#create_tracking_and_charge'

              #///////////////////#
              # WHOLESALER ROUTES #
              #///////////////////#
  get '/wholesaler' => redirect('/wholesaler/profile')
  get '/wholesaler/profile' => 'wholesalers#profile'
  get '/wholesaler/accounts' => 'wholesalers#accounts', as: :wholesaler_accounts
  get '/wholesaler/company' => 'wholesalers#company'
  get '/new_product' => 'wholesalers#new_product'
  get '/approve_product/:id' => 'wholesalers#approve_product'
  put '/launch_product/:id' => 'wholesalers#launch_product'
  get '/past_products' => 'wholesalers#past_products'
  get '/manage_shipping' => 'wholesalers#manage_shipping'
  get '/analytics' => 'wholesalers#analytics'
  get '/needs_attention' => 'wholesalers#needs_attention'
  get '/account_verify' => 'users#accounts_verify', as: :accounts_verify
  get '/needs_shipping' => 'wholesalers#needs_shipping', as: :needs_shipping
  get '/needs_shipping/:product_id' => 'wholesalers#show_needs_shipping'
  get '/wholesaler/settings' => 'wholesalers#settings'
  get '/settings/wholesaler/change_password' => 'wholesalers#change_password'
  put '/settings/wholesaler/change_password' => 'wholesalers#change_password'
  get '/wholesaler/product/:id' => 'products#wholesaler_show'
  get '/current_sales' => 'wholesalers#current_sales'
  get '/already_printed' => 'wholesalers#already_printed'


                #///////////////////#
                #  RETAILER ROUTES  #
                #///////////////////#
  get '/retailer' => redirect('/retailer/pending_orders')
  get '/retailer/pending_orders' => 'retailers#index'
  get '/retailer/accounts' => 'retailers#accounts'
  get '/retailer/order_history' => 'retailers#order_history'
  get '/retailer/settings' => 'retailers#settings'
  get '/retailer/shipping_addresses' => 'retailers#shipping_addresses'
  get '/retailer/company' => 'retailers#company'
  get '/retailer/settings/change_password' => 'retailers#change_password'
  put '/retailer/settings/change_password' => 'retailers#change_password'
  get '/retailer/:order/card_declined' => 'retailers#card_declined'

                #///////////////////#
                #   ADMIN ROUTES    #
                #///////////////////#

  get '/admin' => 'admin#index'

                #///////////////////#
                #  PRODUCT ROUTES   #
                #///////////////////#
  get '/shop' => 'welcome#shop', as: :shop
  get '/tech' => 'welcome#tech'
  get '/accessories' => 'welcome#accessories'
  get '/home_goods' => 'welcome#home_goods'
  get '/apparel' => 'welcome#apparel'
  get '/ending_soon' => 'welcome#ending_soon'
  get '/best_sellers' => 'welcome#best_sellers'
  get '/new_arrivals' => 'welcome#new_arrivals'
  get '/regularly_priced' => 'welcome#regularly_priced'
  get '/company/:key' => 'welcome#company_show'
  get '/products/:token/:slug' => 'products#full_price'
  get '/discover' => 'products#discover'

  post '/sessions' => 'sessions#create'
  delete '/sessions' => 'sessions#destroy'
  get '/logout' => 'users#logout'

  root 'users#index'
  get '/signup' => 'users#signup'
  get '/forgot_password' => 'users#forgot_password'
  get '/reset_password/:token' => 'users#reset_password'
  get '/about' => 'users#about'
  get '/faq' => 'users#faq'
  get '/why_bluebird' => 'users#why'
  get '/apply' => 'users#apply'
  get '/thank_you' => 'users#thank_you'

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
