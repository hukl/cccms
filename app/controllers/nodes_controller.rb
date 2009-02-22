class NodesController < ApplicationController
  
  layout 'admin'
  before_filter :login_required
  before_filter :find_node, :only => [
                              :show, 
                              :edit, 
                              :update, 
                              :destroy,
                              :publish
                            ]

  def index
    @nodes = Node.root.descendants.paginate( 
      :include => :head, 
      :page => params[:page], 
      :per_page => 25,
      :order => 'id DESC'
    )
  end

  def new
    @node = Node.new params[:node]
  end

  def create
    parent = Node.find_by_unique_name(params[:parent_unique_name])
    parent ||= Node.root
    
    @node = Node.new( params[:node] )
    
    if request.post? and @node.save
      @node.move_to_child_of parent
      redirect_to(@node)
    else
      render :action => :new
    end
  end

  def show
    @nodes = Node.find(params[:id]).children
  end

  def edit
    
  end

  def update
    draft = @node.find_or_create_draft current_user
    
    if draft.update_attributes( params[:page] )
      redirect_to(@node)
    else
      render :action => :edit
    end
  end

  def destroy
    @node.destroy
  end
  
  def publish
    @node.publish_draft!
    flash[:notice] = "Draft has been published"
    redirect_to node_path
  end
  
  def move_to
    parent = Node.find params[:parent_id]
    @node.move_to_child_of parent
    redirect_to(@node)
  end
  
  private
  
    def find_node
      @node = Node.find(params[:id])
    end
end
