class Authentication < ActiveRecord::Base
  belongs_to :user
  serialize :token, Hash
  
  SUPPORTED_SERVICES = { 
     :google   => [ :openid_url => "https://www.google.com/accounts/o8/id" ],
     :yahoo    => [ :openid_url => "https://yahoo.com" ],
     :aol      => [ :openid_url => "https://aol.com" ],
     :facebook => [:facebook ]
  }

  validates :token, :uniqueness => true
  
  def get_user_data
    Users::OmniauthCallbacksController.build_registration_hash(slef.token)
  end
  
end
