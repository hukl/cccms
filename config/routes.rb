ActionController::Routing::Routes.draw do |map|
  map.root( 
    :locale => 'de',
    :controller => 'content', 
    :action => 'render_page',
    :page_path => ['home']
  )
  
  map.filter :locale
  
  map.resources :pages
  map.resources :nodes, :member => {:publish => :put}
  
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login',   :controller => 'sessions', :action => 'new'
  map.resources :users
  map.resource  :session
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  map.connect   '/*page_path',
                :controller => 'content', :action => 'render_page'
end
