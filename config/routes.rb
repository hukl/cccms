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
  map.resources :pages,     :member => {:preview => :get, :sort_images => :put}
  map.resources :nodes,     :member => {:publish => :put, :unlock => :put} do |node|
    node.resources :revisions, :member => {:restore => :put}, :collection => {:diff => :post}
  end
  map.logout    '/logout',  :controller => 'sessions', :action => 'destroy'
  map.login     '/login',   :controller => 'sessions', :action => 'new'
  map.admin_search 'admin/search', :controller => 'admin', :action => 'search'
  map.search    'search',   :controller => "search", :action => 'index'
  map.resources :users
  map.resources :menu_items, :member => {:sort => :post}
  map.resource  :session

  map.rss       'rss/:action',         :controller => 'rss'
  map.rss       'rss/:action.:format', :controller => 'rss'

  map.connect   ':controller/:action/:id'
  map.connect   ':controller/:action/:id.:format'

  map.connect   'galleries/*page_path',
                :controller => 'content', :action => 'render_gallery'

  map.content   '/*page_path',
                :controller => 'content', :action => 'render_page'
end
