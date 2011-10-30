class PagesController < ApplicationController

  # Private

  before_filter :login_required

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
    page.update_assets(params[:images])

    render :nothing => true, :status => 200
  end
end
