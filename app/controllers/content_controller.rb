class ContentController < ApplicationController

  def render_page
    path = params[:pagepath].join('/')
    
    @page = Node.find_page(path)
    
    # Replace with real 404
   render :status => 404 unless @page
  end

end
