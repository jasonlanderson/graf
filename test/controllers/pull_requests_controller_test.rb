require 'test_helper'

class PullRequestsControllerTest < ActionController::TestCase
  setup do
    @pull_request = pull_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pull_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pull_request" do
    assert_difference('PullRequest.count') do
      post :create, pull_request: { body: @pull_request.body, date_closed: @pull_request.date_closed, date_created: @pull_request.date_created, date_merged: @pull_request.date_merged, date_updated: @pull_request.date_updated, git_id: @pull_request.git_id, pr_number: @pull_request.pr_number, repo_id: @pull_request.repo_id, state: @pull_request.state, title: @pull_request.title, user_id: @pull_request.user_id }
    end

    assert_redirected_to pull_request_path(assigns(:pull_request))
  end

  test "should show pull_request" do
    get :show, id: @pull_request
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @pull_request
    assert_response :success
  end

  test "should update pull_request" do
    patch :update, id: @pull_request, pull_request: { body: @pull_request.body, date_closed: @pull_request.date_closed, date_created: @pull_request.date_created, date_merged: @pull_request.date_merged, date_updated: @pull_request.date_updated, git_id: @pull_request.git_id, pr_number: @pull_request.pr_number, repo_id: @pull_request.repo_id, state: @pull_request.state, title: @pull_request.title, user_id: @pull_request.user_id }
    assert_redirected_to pull_request_path(assigns(:pull_request))
  end

  test "should destroy pull_request" do
    assert_difference('PullRequest.count', -1) do
      delete :destroy, id: @pull_request
    end

    assert_redirected_to pull_requests_path
  end
end
