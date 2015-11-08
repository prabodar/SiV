require 'open-uri'
class SessionsController < ApplicationController
  
  
  
  def create
    user = User.from_omniauth(env["omniauth.auth"])
    
    session[:user_id] = user.id
    session[:user_ip] = request.remote_ip
    user.ip_address = request.remote_ip
   # puts user.ip_address
    user.log_last_connection = 'log_last'
    puts user
   # puts user.log_last_connection
    user.save!
    puts "is_read_stream called!"
    if is_read_stream(user) == "user_videos"
      puts "read_stream was approved!"
      redirect_to root_url
    else
      puts "read_stream was not approved!"
      redirect_to "/auth/facebook", id: "sign_in"
    end
  end

  def destroy
    session[:user_id] = nil
    session[:user_ip] = nil
    redirect_to root_url
  end  
  
  def is_read_stream(user)
    request_url = "https://graph.facebook.com/v2.0/" + user.uid + "/permissions?access_token=" + user.oauth_token 
    puts request_url
    raw_data = open(request_url).read
    puts "here is read streammmmmm"
     puts raw_data
    json_data = JSON.parse(raw_data)
    puts json_data['data'][0]['permission']
    begin
    json_data['data'][0]['permission'] 
     # json_data['data']['permission']
     # puts json_data['data']['permission']
    rescue Exception
      1
    end
  end
 

end
