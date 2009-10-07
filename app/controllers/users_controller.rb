class UsersController < ApplicationController
  
  # Private
  
  before_filter :login_required
  before_filter :verify_admin_status, :except => [:index, :show]
  
  layout 'admin'
  
  def index
    @users = User.all(:order => "login ASC")
  end

  def new
    @user = User.new( params[:user] )
  end

  def create
    @user = User.new params[:user]
    
    if @user.save
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    
    if @user.update_attributes(params[:user])
      redirect_to user_path(@user)
    else
      render :edit
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def destroy
    user = User.find(params[:id])
    user.destroy if user
    redirect_to users_path
  end

  private
    def verify_admin_status
      unless current_user.admin
        flash[:notice] = "Sorry, you need to be an admin for this action"
        redirect_to users_path
      end
    end
end
