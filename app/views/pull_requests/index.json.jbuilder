json.array!(@pull_requests) do |pull_request|
  json.extract! pull_request, :id, :repo_id, :user_id, :git_id, :pr_number, :body, :title, :state, :date_created, :date_closed, :date_updated, :date_merged
  json.url pull_request_url(pull_request, format: :json)
end
