class NodesController < ApplicationController
  
  layout 'admin'
  before_filter :login_required
  before_filter :find_node, :only => [
                              :show, 
                              :edit, 
                              :update, 
                              :destroy,
                              :publish,
                              :unlock
                            ]

  def index
    @nodes = Node.root.descendants.paginate( 
      :include => [:head, :draft],
      :page => params[:page], 
      :per_page => 25,
      :order => 'id DESC'
    )
  end

  def new
    @node = Node.new params[:node]
  end

  def create
    @node = Node.new( params[:node] )
    
    parent = Node.find(params[:parent_id])
    
    if parent and @node.save
      @node.move_to_child_of parent
      redirect_to(edit_node_path(@node))
    else
      @node.errors.add("Parent node")
      render :action => :new
    end
  end

  def show
    @page = Node.find(params[:id]).pages.last
  end

  def edit
    begin
      @draft = @node.find_or_create_draft( current_user )
    rescue LockedByAnotherUser
      flash[:error] = "Page is locked by another user who is working on it!"
      redirect_to :back
    end
  end

  def update
    @draft = @node.find_or_create_draft current_user
    @draft.tag_list = params[:tag_list]
    if @draft.update_attributes( params[:page] )
      flash[:notice] = "Draft has been saved: #{Time.now}"
      respond_to do |format|
        format.html { redirect_to edit_node_path(@node) }
        format.js
      end
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
  
  def unlock
    # TODO that actually has to be implemented in the model, once we have
    # permissions
    if @node.lock_owner
      @node.unlock!
      flash[:notice] = "Node unlocked"
    else
      flash[:notice] = "Cannot unlock"
    end
    
    redirect_to nodes_path
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
