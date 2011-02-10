class AdminController < ApplicationController
  
  # Private
  
  before_filter :login_required

  def index
    @drafts = Node.all(
      :limit => 20,
      :order => "updated_at desc",
      :conditions => ["draft_id IS NOT NULL"]
    )
    @recent_changes = Node.all(
      :limit => 20,
      :order => "updated_at desc",
      :conditions => [ 
        "updated_at < ? AND updated_at > ? AND parent_id IS NOT NULL", Time.now, Time.now-14.days
      ]
    )
  end
  
  def search
    @results = Node.search params[:search_term]
    
    respond_to do |format|
      format.html
      format.js do 
        render( :json => @results.map do |node| 
          {:id => node.id, :title => node.title, :edit_path => node_path(node)} 
          end
        )
        
      end 
    end
  end
  
  def menu_search
    if params[:search_term] == "Root"
      @results = [Node.root]
    else
      @results = Node.search params[:search_term]
    end
    
    respond_to do |format|
      format.html do
        render :partial => 'admin/menu_search_results'
      end
      
      
      format.js do 
        render( :json => @results.map do |node| 
          {:node_id => node.id, :title => node.title, :unique_name => node.unique_name} 
          end
        )
        
      end 
    end
  end
  
end
