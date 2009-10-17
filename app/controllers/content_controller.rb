class ContentController < ApplicationController
  
  # Public
  
  before_filter :find_page
  
  # This is the method that renders most of the the public content. It recieves
  # a :locale and a :page_path parameter through the params hash. It looks up 
  # the node with the corresponding unique_name attribute. The method doesn't
  # return a node though, the node is really a proxy object for pages. It 
  # returns the most recent page associated to this node instead.
  def render_page
    
    expires_in 10.minutes, :public => true
    
    if @page and @page.public?
      render(
        :file => @page.valid_template,
        :layout => true
      )
    else
      render( 
        :file => File.join(RAILS_ROOT, 'public', '404.html'),
        :status => 404
      )
    end
    
  end

  def render_gallery
    @images = @page.assets.images
    render :file => "content/gallery"
  end
  
  private
    def find_page
      path = params[:page_path].join('/')
      @page = Node.find_page(path)
    end
end
