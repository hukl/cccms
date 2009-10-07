module UsersHelper
  def user_list_by_admin_status
    if current_user && current_user.admin
      render :partial => 'admin_user_item', :collection => @users
    else
      render :partial => 'user_item', :collection => @users
    end
  end
end
