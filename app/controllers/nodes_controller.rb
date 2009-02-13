class NodesController < ApplicationController
  
  layout 'admin'
  
  def index
    @nodes = Node.root.children.all(:include => :head)
  end

  def new
  end

  def create
  end

  def show
    @nodes = Node.find(params[:id]).children
  end

  def edit
    node = Node.find(params[:id])
    @page = node.find_or_create_draft current_user
  end

  def update
  end

  def destroy
  end

end
