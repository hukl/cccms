class RevisionsController < ApplicationController
  
  layout 'admin'
  
  def index
  end

  def diff
    @node = Node.find(params[:id])
    
    puts @node.pages.length
    if @node.pages.length > 1
      params[:start_revision]  ||= @node.pages.all[-2].revision
      params[:end_revision]    ||= @node.pages.all[-1].revision
    else
      params[:start], params[:end] = 1, 1
    end
    
    @start = Page.find( :first, :conditions => {
      :node_id => params[:id],
      :revision => params[:start_revision]
    })
    
    @end = Page.find( :first, :conditions => {
      :node_id => params[:id],
      :revision => params[:end_revision]
    })
    
  end

  def show
    @node = Node.find(params[:id])
  end

  def restore
    page = Page.find(params[:id])
    page.node.restore_revision! page.revision
    flash[:notice] = "Revision #{page.revision} restored"
    redirect_to :back
  end
end
