json.extract! @user, :id, :name, :email, :uid, :location, :created_at, :updated_at, :ip_address
if @user.log_last_connection != nil
  json.geolocation JSON.parse(@user.log_last_connection)['geolocation_data']
else
  json.geolocation nil
end