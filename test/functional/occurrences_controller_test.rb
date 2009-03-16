require 'test_helper'

class OccurrencesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:occurrences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create occurrence" do
    assert_difference('Occurrence.count') do
      post :create, :occurrence => { }
    end

    assert_redirected_to occurrence_path(assigns(:occurrence))
  end

  test "should show occurrence" do
    get :show, :id => occurrences(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => occurrences(:one).to_param
    assert_response :success
  end

  test "should update occurrence" do
    put :update, :id => occurrences(:one).to_param, :occurrence => { }
    assert_redirected_to occurrence_path(assigns(:occurrence))
  end

  test "should destroy occurrence" do
    assert_difference('Occurrence.count', -1) do
      delete :destroy, :id => occurrences(:one).to_param
    end

    assert_redirected_to occurrences_path
  end
end
