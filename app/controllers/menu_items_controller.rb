class MenuItemsController < ApplicationController
  
  layout 'admin'
  
  def index
    @menu_items = MenuItem.all
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
  end

  def update
  end

  def delete
  end

end
