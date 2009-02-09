class NodesController < ApplicationController
  include Auditing

  layout 'admin'
  
  before_filter :find_node, :only => [:create, :show, :edit, :update, :destroy]
  

  def index
    @nodes = Node.root.children.all(:include => :head)
  end

  def new
  end

  def create
    tmp_node = Node.new( params[:node] )
    
    if request.post? and tmp_node.save
      tmp_node.move_to_child_of @node
      redirect_to(tmp_node)
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
    draft.update_attributes params[:page]
    draft.save
  end

  def destroy
  end
  
  private
  
    def find_node
      @node = Node.find(params[:id])
    end
end
