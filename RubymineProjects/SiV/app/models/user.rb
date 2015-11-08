class User < ActiveRecord::Base
  
  has_many :videos, :dependent => :destroy 
 # geocoded_by :ip_address
  #after_validation :geocode

  #reverse_geocoded_by :latitude, :longitude do |obj,results|
  #if geo = results.first
  #  obj.city    = geo.city
  #end
#end
#after_validation :reverse_geocode

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.location = auth.info.location
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)     
    
      user.save!
    
    end
  end
  def self.facebook(auth)
     Koala.config.api_version = "v2.2"
   # access_token = auth['token']
  @graph = Koala::Facebook::API.new(auth.credentials.token)
    friends = @graph.get_connections("me", "friends")
    list = Array.new
    friends.each do |hash|
      list.push(hash['id'])
    puts list.last
      
    end
    return list
    #puts self.name
   # @facebook ||= Koala::Facebook::API.new( session[].oauth_token) 
   end
#   def self.friendslist 
#     self.facebook {|fb| fb.get_connection("me", "friends")}.each do |hash| 
#           #self.friends.where(:name => hash['name'], :uid => hash['id']).first_or_create 
#           puts hash
#           end   
#         end
  
  

end
