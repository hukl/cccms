require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  test "get index as regular user renders stripped partial" do
    login_as :quentin
    get :index
    assert_response :success
    assert_select "a", { :count => 0, :text => "Destroy" }
  end
  
  test "get index as admin user renders admin partial" do
    login_as :aaron
    get :index
    assert_response :success
    assert_select "a", "destroy"
    assert_select "a", "show", "Show Link is missing"
  end
  
  test "get new when logged in as admin" do
    login_as :aaron
    get :new
    assert_response :success
  end
  
  test "get new without being logged in as admin redirects back to index" do
    login_as :quentin
    get :new
    assert_response :redirect
    assert_redirected_to users_path
    assert_equal(
      "Sorry, you need to be an admin for this action", 
      @response.flash[:notice]
    )
  end
  
  test "creating new users being logged in as admin" do
    login_as :aaron
    assert_difference "User.count", +1 do
      post :create, :user => {
        :login                  => "peter",
        :email                  => "foo@bar.com",
        :password               => "xxxzzz",
        :password_confirmation  => "xxxzzz"
      }
    end
    
    assert_redirected_to user_path(User.last)
    assert !User.last.admin
  end
  
  test "creating new admin users being logged in as admin" do
    login_as :aaron
    assert_difference "User.count", +1 do
      post :create, :user => {
        :login                  => "peter",
        :email                  => "foo@bar.com",
        :password               => "xxxzzz",
        :password_confirmation  => "xxxzzz",
        :admin                  => true
      }
    end
    
    assert_redirected_to user_path(User.last)
    assert User.last.admin
  end
  
  test "creating new users not being logged as regular user wont work" do
    login_as :quentin
    assert_no_difference "User.count" do
      post :create, :user => {
        :login                  => "peter",
        :email                  => "foo@bar.com",
        :password               => "xxxzzz",
        :password_confirmation  => "xxxzzz"
      }
    end
    
    assert_redirected_to users_path
    assert_equal(
      "Sorry, you need to be an admin for this action", 
      @response.flash[:notice]
    )
  end
  
  test "get edit of another user being logged in as regular user wont work" do
    login_as :quentin
    get :edit, :id => User.find_by_login("aaron").id
    assert_redirected_to users_path
    assert_equal(
      "Sorry, you need to be an admin for this action", 
      @response.flash[:notice]
    )
  end
  
  test "get edit of another user being logged in as admin user" do
    login_as :aaron
    get :edit, :id => User.find_by_login("quentin").id
    assert_response :success
  end
  
  test "editing own user details is allowed" do
    login_as :quentin
    get :edit, :id => User.find_by_login("quentin").id
    assert_response :success
  end
  
  test "updating an user when being logged in as regular user wont work" do
    user = User.find_by_login("aaron")
    login_as :quentin
    put :update, :id => user.id, :user => {:login => "random"}
    assert_redirected_to users_path
    assert_equal(
      "Sorry, you need to be an admin for this action", 
      @response.flash[:notice]
    )
  end
  
  test "updating an user when being login in as admin user" do
    user = User.find_by_login("quentin")
    login_as :aaron
    put :update, :id => user.id, :user => {:login => "random"}
    assert_redirected_to user_path(user)
    assert_equal "random", user.reload.login
  end
  
  test "updating own user details is allowd" do
    user = User.find_by_login("quentin")
    login_as :quentin
    put :update, :id => user.id, :user => {:login => "random"}
    assert_redirected_to user_path(user)
    assert_equal "random", user.reload.login
  end
  
  test "showing a user" do
    login_as :quentin
    get :show, :id => User.find_by_login("aaron").id
    assert_response :success
  end
  
  test "destroying an user being logged in as regular user wont work" do
    login_as :quentin
    assert_no_difference "User.count" do
      delete :destroy, :id => User.find_by_login("aaron").id
    end
    assert_redirected_to users_path
    assert_equal(
      "Sorry, you need to be an admin for this action", 
      @response.flash[:notice]
    )
  end
  
  test "destroying an user being logged in as admin user" do
    login_as :aaron
    assert_difference "User.count", -1 do
      delete :destroy, :id => User.find_by_login("quentin").id
    end
    assert_redirected_to users_path
  end
  
  
end
