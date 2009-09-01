class PagesController < ApplicationController
    
  def preview
    @page = Page.find(params[:id])
    
    if @page
      template = @page.valid_template
      render(
        :file => template,
        :layout => "application"
      )
    end
    
  end
  
  
  def sort_images
    page = Page.find(params[:id])
    
    page.related_assets.destroy_all
    
    params[:images].each_with_index do |id, index|
      asset = Asset.find(id)
      page.related_assets.create(:asset_id => asset.id, :position => index+1)
    end
    
    render :nothing => true, :status => 200
  end
end
