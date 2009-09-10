class RssController < ApplicationController
  
  def updates
    
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
