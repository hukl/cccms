class ContentController < ApplicationController

  def render_page
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
