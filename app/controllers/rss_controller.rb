class RssController < ApplicationController
  
  def updates
    @host = request.protocol + request.host_with_port
    
    @items = Page.heads.find_tagged_with(
      "update",
      :order => "published_at DESC",
      :limit => 20
    )
    
    respond_to do |format|
      format.xml {}
    end
  end

end
