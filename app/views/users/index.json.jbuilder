json.array!(@users) do |user|
  json.extract! user, :id, :company_id, :git_id, :login, :name, :location, :email, :date_created, :date_updated
  json.url user_url(user, format: :json)
end
