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
    respond_to do |format|
      format.html {}
      
      format.js do
        MenuItem.create params[:menu_item]
      end
      
      
    end
    
    
  end

  def edit
  end

  def update
  end

  def delete
  end

end
