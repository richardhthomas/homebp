require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test "should get menu" do
    get :menu
    assert_response :success
  end

  test "should get index_users" do
    get :index_users
    assert_response :success
  end

  test "should get index_current_bps" do
    get :index_current_bps
    assert_response :success
  end

  test "should get index_average_bps" do
    get :index_average_bps
    assert_response :success
  end

  test "should get delete_user" do
    get :delete_user
    assert_response :success
  end

  test "should get delete_current_bp" do
    get :delete_current_bp
    assert_response :success
  end

  test "should get delete_average_bp" do
    get :delete_average_bp
    assert_response :success
  end

  test "should get mail" do
    get :mail
    assert_response :success
  end

end
