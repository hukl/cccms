class MenuItemsController < ApplicationController
  
  layout 'admin'
  
  def index
    @menu_items = MenuItem.all
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def delete
  end

end
