json.array!(@commits) do |commit|
  json.extract! commit, :id, :repo_id, :user_id, :sha, :message, :date_created, :created_at, :updated_at
  json.url commit_url(commit, format: :json)
end
