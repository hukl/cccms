class MenuItemsController < ApplicationController

  # Private

  before_filter :login_required

  layout 'admin'

  def index
    @menu_items = MenuItem.all(:order => "position ASC")
  end

  def show
  end

  def new
    @menu_item = MenuItem.new params[:menu_item]
  end

  def create
    if MenuItem.create( params[:menu_item] )
      redirect_to menu_items_path
    else
      render :new
    end
  end

  def edit
    @menu_item = MenuItem.find( params[:id] )
  end

  def update
    @menu_item = MenuItem.find( params[:id] )

    if @menu_item.update_attributes( params[:menu_item] )
      redirect_to menu_items_path
    else
      render :edit
    end
  end

  def destroy
    menu_item = MenuItem.find( params[:id] )
    menu_item.destroy
    redirect_to menu_items_path
  end

  def sort
    params[:menu_items].each_with_index do |item_id, index|
      menu_item = MenuItem.find(item_id)
      menu_item.update_attributes(:position => index + 1)
    end

    render :nothing => true
  end

end
