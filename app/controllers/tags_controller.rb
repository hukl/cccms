class TagsController < ApplicationController
  
  # Public
  
  def index
  end

  def show
    @tag    = Tag.find_by_name(params[:id])
    
    tag_name = @tag ? @tag.name : nil
    
    @page   = Page.new
    @pages  = Page.heads.paginate(
      Page.find_options_for_find_tagged_with(tag_name).merge(
        :order => 'published_at DESC',
        :page=>params[:page],
        :per_page => 23
      )
    )
  end

end
