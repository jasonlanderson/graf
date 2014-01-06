json.array!(@github_load_msgs) do |github_load_msg|
  json.extract! github_load_msg, :id, :github_load_id, :msg, :log_level, :log_date
  json.url github_load_msg_url(github_load_msg, format: :json)
end
