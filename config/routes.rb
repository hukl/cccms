ActionController::Routing::Routes.draw do |map|
  
  map.connect   ':language/*pagepath',
                :controller => 'content', :action => 'render_page', 
                :requirements => {:language => /\w{2}/}
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
