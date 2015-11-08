json.array!(@users) do |user|
  json.extract! user, :id, :name, :email, :uid, :location
  json.url user_url(user, format: :json)
end
