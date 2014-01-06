require 'test_helper'

class GithubLoadsControllerTest < ActionController::TestCase
  setup do
    @github_load = github_loads(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:github_loads)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create github_load" do
    assert_difference('GithubLoad.count') do
      post :create, github_load: { initial_load: @github_load.initial_load, load_complete_time: @github_load.load_complete_time, load_start_time: @github_load.load_start_time }
    end

    assert_redirected_to github_load_path(assigns(:github_load))
  end

  test "should show github_load" do
    get :show, id: @github_load
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @github_load
    assert_response :success
  end

  test "should update github_load" do
    patch :update, id: @github_load, github_load: { initial_load: @github_load.initial_load, load_complete_time: @github_load.load_complete_time, load_start_time: @github_load.load_start_time }
    assert_redirected_to github_load_path(assigns(:github_load))
  end

  test "should destroy github_load" do
    assert_difference('GithubLoad.count', -1) do
      delete :destroy, id: @github_load
    end

    assert_redirected_to github_loads_path
  end
end
