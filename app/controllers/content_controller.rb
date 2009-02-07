class ContentController < ApplicationController
  
  # This is the method that renders most of the the public content. It recieves
  # a :locale and a :page_path parameter through the params hash. It looks up 
  # the node with the corresponding unique_name attribute. The method doesn't
  # return a node though, the node is really a proxy object for pages. It 
  # returns the most recent page associated to this node instead.
  def render_page
    I18n.locale = params[:language]
    path = params[:page_path].join('/')
    
    @page = Node.find_page(path)
    
    # Replace with real 404
    unless @page
      render( 
        :file => File.join(RAILS_ROOT, 'public', '404.html'),
        :status => 404
      )
    end
    
  end
end
