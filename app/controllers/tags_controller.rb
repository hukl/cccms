class TagsController < ApplicationController

  # Public

  def index
    @page = Page.new :title => "Tags"

    @tags = Tag.all(:limit => 500)
  end

  def show
    @tag    = Tag.find_by_name(params[:id])

    @tag = @tag ? @tag.name : params[:id]

    @page   = Page.new

    params[:page] = ( params[:page].is_a?(Fixnum) ? params[:page] : 1 )

    @pages  = Page.heads.paginate(
      Page.find_options_for_find_tagged_with(@tag).merge(
        :order => 'published_at DESC',
        :page=>params[:page],
        :per_page => 23
      )
    )

    respond_to do |format|
      format.html {}
    end
  end

end
