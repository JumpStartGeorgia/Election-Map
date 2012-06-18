require 'test_helper'

class CoreIndicatorsControllerTest < ActionController::TestCase
  setup do
    @core_indicator = core_indicators(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:core_indicators)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create core_indicator" do
    assert_difference('CoreIndicator.count') do
      post :create, core_indicator: @core_indicator.attributes
    end

    assert_redirected_to core_indicator_path(assigns(:core_indicator))
  end

  test "should show core_indicator" do
    get :show, id: @core_indicator.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @core_indicator.to_param
    assert_response :success
  end

  test "should update core_indicator" do
    put :update, id: @core_indicator.to_param, core_indicator: @core_indicator.attributes
    assert_redirected_to core_indicator_path(assigns(:core_indicator))
  end

  test "should destroy core_indicator" do
    assert_difference('CoreIndicator.count', -1) do
      delete :destroy, id: @core_indicator.to_param
    end

    assert_redirected_to core_indicators_path
  end
end
