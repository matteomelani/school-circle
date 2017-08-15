class Invitation < ActiveRecord::Base
  serialize :registration_info, Hash
  belongs_to :inviter, :class_name => 'User'
  belongs_to :circle
  
  after_initialize :set_token, :set_expiration, :set_optional_message, :set_registration_info
  
  STANDARD_VALIDITY = 30   # an invitation is valid for 30 days from the day it is created
    
  # First and last name can only contains letters
  #TODO: dry this code the reg ex is copied from the devise config file
  EMAIL_REGEX = /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  validates :email, :presence=>true, :format => { :with => EMAIL_REGEX }
  validates :inviter_id, :presence => true
  validates :token, :presence => true, :uniqueness => true
  validates :expires_on, :presence => true
  validates :circle_id, :presence => true
  
            
  include HasAvatar
  has_avatar
             
  def self.generate_token
    loop do
      token = SecureRandom.base64(15).tr('+/=', 'xyz')
      break token if Invitation.where(:token => token).empty?      
    end
  end
  
  def registration_hash
    rh = {
      :email=>email,
      :profile_attributes=>{},
      :skip_confirmation=>true,  # invited user do not need email confirmation
      :memberships=>registration_info[:memberships]
    }
    [:first_name, :last_name, :sex, :birthday, :location, :time_zone, :main_role ].each do |key|
      rh[:profile_attributes] = rh[:profile_attributes].merge({key=>registration_info[key]}) if registration_info[key]
    end
    rh
  end
  
  def memberships
    ms=[]
    if self.registration_hash[:memberships]
      self.registration_hash[:memberships].each do |m|
        ms << Membership.new(:circle_id => m[:circle_id], :roles => m[:roles])
      end
    end
    return ms
  end
  
  def accept
    user = User.find_by_email(self.email)
    if user.nil?
      logger.error("Could not apply invitation #{self.id} because could not find user with email #{self.email}.")
      return false
    end   
    if self.registration_hash[:memberships]
      self.registration_hash[:memberships].each do |m|
        circle= Circle.find(m[:circle_id])
        if circle.nil?
          logger.info("Circle with id: #{m[:circle_id]} cannot be found.")
          return false
        end
        if user.memberships.exists?(:circle_id=>m[:circle_id])
          logger.info("User #{user.username} is already a member of circle #{m[:circle_id]} with roles #{m[:roles].to_s}")
          return false
        else
          # user can only have one MY_FAMILY membership to a family
          if circle.source.is_a?(Family) and user.my_family 
            m[:roles].delete(Family::MY_FAMILY)
          end 
          user.memberships.create!(:circle_id => m[:circle_id], :roles => m[:roles])
          logger.debug("User #{user.username} is now member of circle #{m[:circle_id]} with roles #{m[:roles].to_s}")
        end
      end
    else
      logger.info("Invitation is missing memberships roles I will use the standard User role: #{Circle::USER_ROLE}.")
      user.memberships.create!(:circle_id=>self.circle_id, :roles=>[Circle::USER_ROLE])       
    end
    self.is_used=true
    self.save!
    return true
  end

  
  private
  def set_token
     unless self.token
       self.token = Invitation::generate_token
     end
  end
  def set_expiration
    unless self.expires_on
       self.expires_on = STANDARD_VALIDITY.days.from_now
    end
  end
  def set_optional_message
    if self.optional_message.blank?
      self.optional_message= I18n.t 'models.invitation.optional_message.default' ,:circle_name=>(self.circle.nil? ? "The School Circle" : self.circle.source.display_name)
    end   
  end
  def set_registration_info
    self.registration_info = self.registration_info || {}
  end
end
