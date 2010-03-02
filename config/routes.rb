Cccms::Application.routes.draw do |map|
    match '/*page_path' => 'content#render_page', :as => :content
    match '/search' => 'search#index', :as => :search
    
    resources :tags
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  
  #  map.filter :locale
  #  
  #  map.root( 
  #    :locale => 'de',
  #    :controller => 'content', 
  #    :action => 'render_page',
  #    :page_path => ['home']
  #  )
  #  map.resources :assets
  #  map.resources :tags
  #  map.resources :occurrences
  #  map.resources :events
  #  map.resources :pages,     :member => {:preview => :get, :sort_images => :put}
  #  map.resources :nodes,     :member => {:publish => :put, :unlock => :put} do |node|
  #    node.resources :revisions, :member => {:restore => :put}, :collection => {:diff => :post}
  #  end
  #  map.logout    '/logout',  :controller => 'sessions', :action => 'destroy'
  #  map.login     '/login',   :controller => 'sessions', :action => 'new'
  #  map.admin_search 'admin/search', :controller => 'admin', :action => 'search'
  #  map.search    'search',   :controller => "search", :action => 'index' 
  #  map.resources :users
  #  map.resources :menu_items, :member => {:sort => :post}
  #  map.resource  :session
  #  
  #  map.rss       'rss/:action',         :controller => 'rss'
  #  map.rss       'rss/:action.:format', :controller => 'rss'
  #  
  #  map.connect   ':controller/:action/:id'
  #  map.connect   ':controller/:action/:id.:format'
  #  
  #  map.connect   'galleries/*page_path',
  #                :controller => 'content', :action => 'render_gallery'
  #  
  #  map.content   '/*page_path',
  #                :controller => 'content', :action => 'render_page'
end
