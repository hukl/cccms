class RevisionsController < ApplicationController
  
  layout 'admin'
  
  def index
  end

  def diff
    @node = Node.find(params[:id])
    
    params[:start]  ||= @node.pages.all[-1].revision
    params[:end]    ||= @node.pages.all[-2].revision
    
    @start = Page.find( :first, :conditions => {
      :node_id => params[:id],
      :revision => params[:start]
    })
    
    @end = Page.find( :first, :conditions => {
      :node_id => params[:id],
      :revision => params[:end]
    })
    
  end

  def show
  end

end
