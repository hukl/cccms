ActionController::Routing::Routes.draw do |map|

  map.filter :locale
  
  map.root( 
    :locale => 'de',
    :controller => 'content', 
    :action => 'render_page',
    :page_path => ['home']
  )
  map.resources :assets
  map.resources :tags
  map.resources :occurrences
  map.resources :events
  map.resources :revisions, :member => {:diff => :post, :restore => :put}
  map.resources :pages,     :member => {:preview => :get, :sort_images => :put}
  map.resources :nodes,     :member => {:publish => :put, :unlock => :put}
  map.logout    '/logout',  :controller => 'sessions', :action => 'destroy'
  map.login     '/login',   :controller => 'sessions', :action => 'new'
  map.admin_search 'admin/search', :controller => 'admin', :action => 'search'
  map.search    'search',   :controller => "search", :action => 'index' 
  map.resources :users
  map.resources :menu_items, :member => {:sort => :post}
  map.resource  :session
  
  map.connect   ':controller/:action/:id'
  map.connect   ':controller/:action/:id.:format'
  
  map.connect   'galleries/*page_path',
                :controller => 'content', :action => 'render_gallery'
  
  map.connect   '/*page_path',
                :controller => 'content', :action => 'render_page'
end
