class UsersController < ApplicationController

  # Private

  before_filter :login_required
  before_filter :find_user,     :only => [:show, :edit, :update, :destroy]
  before_filter :verify_status, :except => [:index, :show]

  layout 'admin'

  def index
    @users = User.all(:order => "login ASC").group_by do |user|
      user.admin? ? :admin : :user
    end
  end

  def new
    @user = User.new( params[:user] )
  end

  def create
    @user = User.new params[:user]

    if @user.save
      flash[:notice] = "User created #{@user.login}"
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def edit
  end

  def update
    params[:user].delete(:admin) unless current_user.is_admin?
    if @user.update_attributes(params[:user])
      flash[:notice] = "Updated user #{@user.login}"
      redirect_to user_path(@user)
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    @user.destroy if @user
    redirect_to users_path
  end

  private
    def find_user
      @user = User.find(params[:id])
    end

    def verify_status
      @user ||= User.new
      unless @user.id == current_user.id || current_user.admin
        deny_user_access
      end
    end

    def deny_user_access
      flash[:notice] = "Sorry, you need to be an admin for this action"
      redirect_to users_path
    end
end
