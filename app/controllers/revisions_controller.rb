class RevisionsController < ApplicationController
  
  layout 'admin'
  
  def index
  end

  def diff
    @node = Node.find(params[:id])
    
    puts @node.pages.length
    if @node.pages.length > 1
      params[:start]  ||= @node.pages.all[-2].revision
      params[:end]    ||= @node.pages.all[-1].revision
    else
      params[:start], params[:end] = 1, 1
    end
    
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
    @node = Node.find(params[:id])
  end

end
