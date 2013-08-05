require 'test_helper'

class CurrentBpsControllerTest < ActionController::TestCase
  setup do
    @current_bp = current_bps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:current_bps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create current_bp" do
    assert_difference('CurrentBp.count') do
      post :create, current_bp: { ampm: @current_bp.ampm, date: @current_bp.date, diabp: @current_bp.diabp, sysbp: @current_bp.sysbp }
    end

    assert_redirected_to current_bp_path(assigns(:current_bp))
  end

  test "should show current_bp" do
    get :show, id: @current_bp
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @current_bp
    assert_response :success
  end

  test "should update current_bp" do
    patch :update, id: @current_bp, current_bp: { ampm: @current_bp.ampm, date: @current_bp.date, diabp: @current_bp.diabp, sysbp: @current_bp.sysbp }
    assert_redirected_to current_bp_path(assigns(:current_bp))
  end

  test "should destroy current_bp" do
    assert_difference('CurrentBp.count', -1) do
      delete :destroy, id: @current_bp
    end

    assert_redirected_to current_bps_path
  end
end
