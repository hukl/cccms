class UsersController < ApplicationController
  
  layout 'admin'
  
  def index
    @users = User.all
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def show
  end

  def destroy
  end

end
