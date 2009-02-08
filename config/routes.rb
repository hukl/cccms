ActionController::Routing::Routes.draw do |map|
  map.resources :pages
  map.resources :nodes

  
  map.connect   ':language/*page_path',
                :controller => 'content', :action => 'render_page', 
                :requirements => {:language => /\w{2}/}
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
