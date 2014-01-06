require 'test_helper'

class GithubLoadMsgsControllerTest < ActionController::TestCase
  setup do
    @github_load_msg = github_load_msgs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:github_load_msgs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create github_load_msg" do
    assert_difference('GithubLoadMsg.count') do
      post :create, github_load_msg: { github_load_id: @github_load_msg.github_load_id, log_date: @github_load_msg.log_date, log_level: @github_load_msg.log_level, msg: @github_load_msg.msg }
    end

    assert_redirected_to github_load_msg_path(assigns(:github_load_msg))
  end

  test "should show github_load_msg" do
    get :show, id: @github_load_msg
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @github_load_msg
    assert_response :success
  end

  test "should update github_load_msg" do
    patch :update, id: @github_load_msg, github_load_msg: { github_load_id: @github_load_msg.github_load_id, log_date: @github_load_msg.log_date, log_level: @github_load_msg.log_level, msg: @github_load_msg.msg }
    assert_redirected_to github_load_msg_path(assigns(:github_load_msg))
  end

  test "should destroy github_load_msg" do
    assert_difference('GithubLoadMsg.count', -1) do
      delete :destroy, id: @github_load_msg
    end

    assert_redirected_to github_load_msgs_path
  end
end
