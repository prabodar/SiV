require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup 
    @env = OmniAuth.config.mock_auth[:facebook] 
  end
  
  test "#from_omniauth finds user if user exists" do
    user = User.create! do |u|
      u.provider = :facebook
      u.uid = "1234567890"
      u.oauth_token = "abcd1234"
      u.oauth_expires_at = Time.at(628232400)
    end

    assert_equal user, User.from_omniauth(@env)
  end
end
