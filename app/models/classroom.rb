class Classroom < ActiveRecord::Base
  
  OWNER_ROLE   = "classroom_owner"
  TEACHER_ROLE = "classroom_teacher"
  PARENT_ROLE  = "classroom_parent"
  UNVERIFIED = 'unverified'
  VERIFIED = 'verified'
  IN_REVIEW ='in_review'

  GRADE_LEVEL=%w(Preschool Preschool-toddler K 1st 2nd 3rd 4th 5th 6th 7th 8th 9th 10th 11th 12th)
  enum_attr :school_association_status, [UNVERIFIED, VERIFIED, IN_REVIEW]
    
  belongs_to :school
  
  include ActsAsCircleSource
  acts_as_circle_source
  
  include HasAvatar
  has_avatar
  def default_avatar_url
    "users_original.png"   
  end
  
end


