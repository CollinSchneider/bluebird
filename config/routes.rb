Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get '/api/stripe_connect_charge' => 'api#stripe_connect_charge'
  post '/api/stripe_connect_charge' => 'api#stripe_connect_charge'

  resources :users
  put 'users/password_reset/:id' => 'users#password_reset'
  resources :products, :except => ['show']
  get '/products/:id/:slug' => 'products#show'
  get '/products/:id/:slug/order' => 'retailers#order'
  get '/last_chance/:token/:slug/order' => 'retailers#full_price_order'
  resources :commits
  resources :wholesalers
  resources :retailers
  resources :companies
  resources :ratings

                  #///////////////////#
                  #     API ROUTES    #
                  #///////////////////#

  get '/api/company/:action' => 'api/company'
  post '/api/company/:action' => 'api/company'

  get '/api/admin/:action' => 'api/admin'
  post '/api/admin/:action' => 'api/admin'

  get '/api/products/:action' => 'api/products'
  post '/api/products/:action' => 'api/products'

  get '/api/payments/:action' => 'api/payments'
  post '/api/payments/:action' => 'api/payments'

  get '/api/wholesalers/:action' => 'api/wholesalers'
  post '/api/wholesalers/:action' => 'api/wholesalers'

  get '/api/shipping/:action' => 'api/shipping'
  post '/api/shipping/:action' => 'api/shipping'

  get '/api/users/:action' => 'api/users'
  post '/api/users/:action' => 'api/users'

  get '/api/orders/:action' => 'api/orders'
  post '/api/orders/:action' => 'api/orders'

              #///////////////////#
              # WHOLESALER ROUTES #
              #///////////////////#
  get '/wholesaler' => redirect('/wholesaler/profile')
  get '/wholesaler/profile' => 'wholesalers#profile'
  get '/wholesaler/accounts' => 'wholesalers#accounts'
  get '/wholesaler/company' => 'wholesalers#company'
  get '/fix_product/:uuid' => 'wholesalers#fix_product'
  post '/fix_product/:uuid' => 'wholesalers#fix_product'
  get '/approve_product/:id' => 'wholesalers#approve_product'
  put '/launch_product/:id' => 'wholesalers#launch_product'
  post '/start_over' => 'wholesalers#start_over'
  get '/past_products' => 'wholesalers#past_products'
  get '/manage_shipping' => 'wholesalers#manage_shipping'
  get '/analytics' => 'wholesalers#analytics'
  get '/needs_attention' => 'wholesalers#needs_attention'
  get '/account_verify' => 'users#accounts_verify'
  get '/needs_shipping' => 'wholesalers#needs_shipping'
  get '/needs_shipping.pdf' => 'wholesalers#needs_shipping'
  get '/needs_shipping/:product_id' => 'wholesalers#show_needs_shipping'
  get '/wholesaler/settings' => 'wholesalers#settings'
  get '/settings/wholesaler/change_password' => 'wholesalers#change_password'
  put '/settings/wholesaler/change_password' => 'wholesalers#change_password'
  get '/wholesaler/product/:id' => 'products#wholesaler_show'
  get '/current_sales' => 'wholesalers#current_sales'
  get '/already_printed.pdf' => 'wholesalers#already_printed'
  get '/relist' => 'wholesalers#relist'

  # WHOLESALER POST PRODUCT
  get '/new_product' => 'wholesalers/new_product#new_product'
  post '/new_product' => 'wholesalers/new_product#new_product'
  get '/new_product_sizing' => 'wholesalers/new_product#new_product_sizing'
  post '/new_product_sizing' => 'wholesalers/new_product#new_product_sizing'
  get '/new_product_variants' => 'wholesalers/new_product#new_product_variants'
  post '/new_product_variants' => 'wholesalers/new_product#new_product_variants'
  get '/new_product_skus' => 'wholesalers/new_product#new_product_skus'
  post '/new_product_skus' => 'wholesalers/new_product#new_product_skus'
  post '/product_has_no_variants' => 'wholesalers/new_product#product_has_no_variants'


                #///////////////////#
                #  RETAILER ROUTES  #
                #///////////////////#
  get '/retailer' => redirect('/retailer/pending_orders')
  get '/retailer/pending_orders' => 'retailers#index'
  get '/retailer/accounts' => 'retailers#accounts'
  get '/retailer/order_history' => 'retailers#order_history'
  get '/retailer/order_history/:id' => 'retailers#show_order_history'
  get '/retailer/order_history/sale_made/:id' => 'retailers#show_order_sale_made'
  get '/retailer/order_history/not_reached/:id' => 'retailers#show_order_not_reached'
  get '/retailer/settings' => 'retailers#settings'
  get '/retailer/shipping_addresses' => 'retailers#shipping_addresses'
  get '/retailer/company' => 'retailers#company'
  get '/retailer/last_chance' => 'retailers#last_chance'
  get '/retailer/settings/change_password' => 'retailers#change_password'
  put '/retailer/settings/change_password' => 'retailers#change_password'
  get '/retailer/:order_id/card_declined' => 'retailers#card_declined'
  get '/retailer/ratings' => 'retailers#ratings'

                #///////////////////#
                #   ADMIN ROUTES    #
                #///////////////////#

  get '/admin' => redirect('/admin/wholesalers')
  get '/admin/wholesalers' => 'admin#wholesalers'
  get '/admin/retailers' => 'admin#retailers'
  get '/admin/features' => 'admin#feature_products'
  get '/admin/unshipped' => 'admin#unshipped'
  get '/admin/signup' => 'users#admin_signup'

                #///////////////////#
                #  PRODUCT ROUTES   #
                #///////////////////#
  get '/shop' => 'welcome#shop'
  get '/tech' => 'welcome#tech'
  get '/accessories' => 'welcome#accessories'
  get '/home_goods' => 'welcome#home_goods'
  get '/apparel' => 'welcome#apparel'
  get '/ending_soon' => 'welcome#ending_soon'
  get '/best_sellers' => 'welcome#best_sellers'
  get '/new_arrivals' => 'welcome#new_arrivals'
  get '/last_chance/:token/:slug' => 'products#full_price'
  get '/discover' => 'products#discover'
  get '/bluebird_choice' => 'products#bluebird_choice'
  get '/category/:category' => 'products#category'

  get '/company/:id/:key' => 'companies#show'
  get '/company/:id/:key/ratings' => 'companies#ratings'
  get '/company/:id/:key/contact' => 'companies#contact'
  post '/company/:id/:key/contact' => 'companies#contact'

  post '/sessions' => 'sessions#create'
  delete '/sessions' => 'sessions#destroy'
  get '/logout' => 'users#logout'

  root 'users#why'
  get '/forgot_password' => 'users#forgot_password'
  get '/reset_password/:token' => 'users#reset_password'
  get '/about' => 'users#about'
  get '/faq' => 'users#faq'
  get '/why_bluebird' => 'users#why'
  get '/apply' => redirect('/users/apply/step1')
  get '/apply/:action' => 'users/apply'
  post '/apply/:action' => 'users/apply'
  get '/signup' => redirect('/signup/step1')
  get '/signup/:action' => 'users/signup'
  post '/signup/:action' => 'users/signup'
  get '/thank_you' => 'users#thank_you'
  get '/choose' => 'users#choose'
  get '/contact' => 'users#contact'
  post '/contact' => 'users#contact'

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
