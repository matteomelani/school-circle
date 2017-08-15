class Group < ActiveRecord::Base
  
  include ActsAsCircleSource
  acts_as_circle_source
  
  include HasAvatar
  has_avatar
  
  def default_avatar_url
     "users_original.png"   
  end
  
end
