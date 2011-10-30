class NodesController < ApplicationController

  # Private

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
    params[:title] ||= ""

    @node = Node.new
    @node.parent_id = find_parent
    @node.slug = params[:title].parameterize.to_s

    if @node.save
      @node.draft.update_attributes(:title => params[:title])
      redirect_to(edit_node_path(@node))
    else
      render :new
    end
  end

  def show
    node = Node.find(params[:id])
    @page = node.draft || node.head
  end

  def edit
    begin
      @draft = @node.find_or_create_draft( current_user )
    rescue LockedByAnotherUser => e
      flash[:error] = e.message
      if request.referer
        redirect_to :back
      else
        redirect_to node_path(@node)
      end
    end
  end

  def update
    @node.update_attributes(params[:node])
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
    if @node.unlock!
      flash[:notice] = "Node unlocked"
    else
      flash[:notice] = "Already unlocked"
    end

    redirect_to node_path(@node)
  end

  private

    def find_node
      @node = Node.find(params[:id])
    end

    def find_parent
      case params[:kind]
      when "top_level"
        Node.root.id
      when "update"
        Update.find_or_create_parent.id
      when "generic"
        if params[:parent_id] && Node.find(params[:parent_id])
          params[:parent_id]
        else
          nil
        end
      end
    end
end
