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
end
