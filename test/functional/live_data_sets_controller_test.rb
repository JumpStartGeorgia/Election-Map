require 'test_helper'

class LiveDataSetsControllerTest < ActionController::TestCase
  setup do
    @live_data_set = live_data_sets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:live_data_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create live_data_set" do
    assert_difference('LiveDataSet.count') do
      post :create, live_data_set: @live_data_set.attributes
    end

    assert_redirected_to live_data_set_path(assigns(:live_data_set))
  end

  test "should show live_data_set" do
    get :show, id: @live_data_set.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @live_data_set.to_param
    assert_response :success
  end

  test "should update live_data_set" do
    put :update, id: @live_data_set.to_param, live_data_set: @live_data_set.attributes
    assert_redirected_to live_data_set_path(assigns(:live_data_set))
  end

  test "should destroy live_data_set" do
    assert_difference('LiveDataSet.count', -1) do
      delete :destroy, id: @live_data_set.to_param
    end

    assert_redirected_to live_data_sets_path
  end
end
