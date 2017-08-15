class School < ActiveRecord::Base

  enum_attr :category, %w(private public charter)

  validates :grade_range, :presence => true  
  
  has_many :classrooms, :order=>:name , :dependent => :destroy
  
  has_many :addresses, :as => :owner, :dependent => :destroy
  accepts_nested_attributes_for :addresses, :allow_destroy => true
  
  has_many :phone_numbers, :as => :owner, :dependent => :destroy
  accepts_nested_attributes_for :phone_numbers, :allow_destroy => true
  
  include HasAvatar
  has_avatar
  
  def default_avatar_url
    "users_original.png"   
  end
  
  include ActsAsCircleSource
  acts_as_circle_source

end
