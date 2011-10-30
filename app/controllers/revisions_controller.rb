class RevisionsController < ApplicationController

  # Private

  before_filter :login_required

  layout 'admin'

  def index
    @node = Node.find(params[:node_id])
  end

  def diff
    @node = Node.find(params[:node_id])

    if @node.pages.length > 1
      params[:start_revision]  ||= @node.pages.all[-2].revision
      params[:end_revision]    ||= @node.pages.all[-1].revision
    else
      params[:start], params[:end] = 1, 1
    end

    @start  = @node.pages.find_by_revision( params[:start_revision] )
    @end    = @node.pages.find_by_revision( params[:end_revision] )
  end

  def show
    @node     = Node.find(params[:node_id])
    @page     = @node.pages.find(params[:id])
  end

  def restore
    page = Page.find(params[:id])
    page.node.restore_revision! page.revision
    flash[:notice] = "Revision #{page.revision} restored"
    redirect_to node_path(page.node)
  end
end
