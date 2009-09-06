class TagsController < ApplicationController
  
  # Public
  
  def index
  end

  def show
    @tag    = Tag.find_by_name(params[:id])
    @page   = Page.new
    @pages  = Page.heads.find_tagged_with(
                @tag.name, :order => 'published_at DESC'
              ).paginate(
                :page=>params[:page],
                :per_page => 23
              )
  end

end
