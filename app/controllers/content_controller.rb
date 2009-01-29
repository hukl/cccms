class ContentController < ApplicationController

  def render_page
    path = params[:page_path].join('/')
    
    @node = Node.find_by_unique_name(path)
    
    # Replace with real 404
   render :status => 404 unless @node
  end

end
