OmniAuth.config.logger = Rails.logger
OmniAuth.config.test_mode = false
OmniAuth.config.add_mock(:facebook, 
  {:uid => '1234567890', 
   :info => {
        :name => "jonmagic"
      },
      :credentials => {
        :token => "abcd1234",
        :secret => "abcd1234",
        :expires_at => 628232400 
      }
    }
  )
#83b0da99506183d8e941bf3373b4ecf2 :display => 'popup'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '354941074694911', 'e00aee938dcc3404857c6c9b2e1bd137',
  :scope => 'email,read_stream,,user_friends,user_videos', :display => 'popup',
  :client_options => {
      :site => 'https://graph.facebook.com/v2.0',
    :authorize_url => "https://www.facebook.com/v2.0/dialog/oauth"
    }
end