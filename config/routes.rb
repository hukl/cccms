ActionController::Routing::Routes.draw do |map|
  map.resources :assets

  map.filter :locale
  
  map.root( 
    :locale => 'de',
    :controller => 'content', 
    :action => 'render_page',
    :page_path => ['home']
  )
  
  map.resources :occurrences
  map.resources :events
  map.resources :revisions, :member => {:diff => :post, :restore => :put}
  map.resources :pages
  map.resources :nodes, :member => {:publish => :put, :unlock => :put}  
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login',   :controller => 'sessions', :action => 'new'
  map.admin_search 'admin/search', :controller => 'admin', :action => 'search'
  map.resources :users
  map.resource  :session
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  map.connect   '/*page_path',
                :controller => 'content', :action => 'render_page'
end
