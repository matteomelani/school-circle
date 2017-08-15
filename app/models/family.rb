class Family < ActiveRecord::Base
  
  ADULT_ROLE = "family_adult"
  KID_ROLE   = "family_kid"
  OWNER_ROLE = "family_owner"
  MY_FAMILY ='family_my_family' # this mark the membership to the user primary family
    
  serialize :languages, Array
  
  after_initialize :set_default_languagues
  
  validates :name, :presence=>true, :length=>{ :maximum => 30 }, :format=>{:with=>/\A[a-zA-Z0-9\-_\s\']+\z/i}
  validates :languages, :presence=>true, :length=>{:minimum => 1}
  
  has_one :location, :as=>:locationable, :dependent=>:destroy
  accepts_nested_attributes_for :location, :allow_destroy=>true, :reject_if=>proc { |attributes| attributes['input_string'].blank? }
  
  attr_accessible :name, :user, :languages, :location_attributes 
  
  include ActsAsCircleSource
  acts_as_circle_source
  
  # override the standard set_up_circle
  def owner_membership_roles
    [Circle::ADMIN_ROLE, Family::ADULT_ROLE, Family::OWNER_ROLE, Family::MY_FAMILY] 
  end
  
  def set_up_circle
    super
    membership = Membership.where(:user_id => self.user.id, :circle_id => self.circle.id).to_a.first
    membership.roles = membership.roles + [Family::ADULT_ROLE, Family::OWNER_ROLE, Family::MY_FAMILY]
    membership.save!
    # reload the membership
    membership = Membership.where(:user_id => self.user.id, :circle_id => self.circle.id).to_a.first
  end
  def default_membership(attributes={})
     attr={:circle=>circle, :roles=>[Circle::ADMIN_ROLE, Family::ADULT_ROLE, Family::MY_FAMILY]}
     roles = attr[:roles] + (attributes[:roles] || [])
     attr=attr.merge(attributes)
     attr[:roles]=roles
     Membership.new(attr)
  end
  
  include HasAvatar
  has_avatar
  def default_avatar_url
    "users_original.png"   
  end
  
  #TODO: convert these to has_many 
  def adult_memberships
    am = circle.memberships.collect {|m| m if m.roles.include?(Family::ADULT_ROLE)} 
    am.compact
  end
  
  def child_memberships
    km = circle.memberships.collect {|m| m if m.roles.include?(Family::KID_ROLE)}
    km.compact
  end
  
  def adults
    a = circle.memberships.collect {|m| m.user if m.roles.include?(Family::ADULT_ROLE)}
    a.compact
  end
  
  def children
     km = circle.memberships.collect {|m| m.user if m.roles.include?(Family::KID_ROLE)}
     km.compact
  end
  
  def add_adult(user)
    m=Membership.new(:user=>user, :circle=>circle, :roles=>[Circle::USER_ROLE, Family::ADULT_ROLE])
    m.save!
  end
  
  def add_parent(user)
    m=Membership.new(:user=>user, :circle=>circle, :roles=>[Circle::ADMIN_ROLE, Family::ADULT_ROLE, Family::MY_FAMILY])
    m.save!
  end
  
  def add_child(user)
    m=Membership.new(:user=>user, :circle=>circle, :roles=>[Circle::USER_ROLE, Family::KID_ROLE, Family::MY_FAMILY])
    m.save!
  end
  
  
  private
  def set_default_languagues
    self.languages ||= []
    self.languages = [self.user.profile_language] if (self.languages.empty? and self.user)
  end
  
   
end




