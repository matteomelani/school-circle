class User < ActiveRecord::Base

  after_initialize :create_profile
  before_save :set_username, :set_auth_token 
  
  before_validation :check_confirmation_bypass
  before_destroy :destroy_classrooms_and_schools_memberships
  
  # username can include a . or - char
  username_regex = /\A[\w+\-.]+\z/i
  validates :username, :allow_blank => true, :allow_nil => nil, :length => {:within =>1..24}, :format => { :with => username_regex },
            :uniqueness => { :case_sensitive => false }
            
  devise :database_authenticatable, :token_authenticatable, :recoverable, :rememberable, :omniauthable, :validatable, :trackable, :timeoutable, :lockable, :confirmable
  
  # A user has one profile that contains all the user basic info liek name, location, etc.
  has_one :profile, :validate => true, :dependent => :destroy
  accepts_nested_attributes_for :profile, :allow_destroy => true, :reject_if =>:all_blank

  
  #TODO: replace with acts_as_circle_source
  after_save :set_up_circle
  has_one :circle, :class_name=> 'Circle', :as => :source
  has_one :personal_circle, :class_name=> 'Circle', :as => :source
  def display_name
    "#{self.profile_full_name}'s Circle"
  end
  def default_membership(attributes={})
    attr={:circle=>circle, :roles=>[Circle::USER_ROLE]}
    roles = attr[:roles] + (attributes[:roles] || [])
    attr=attr.merge(attributes)
    attr[:roles]=roles
    Membership.new(attr)
  end
  def set_up_circle
    if self.profile.is_not_child? and self.personal_circle.nil?
      self.personal_circle = Circle.new(
      :name => "#{self.profile_full_name.blank? ? self.username : self.profile_full_name}'s Personal Circle",
      :source => self,
      :owner => self,
      :description => "This is the personal circle of #{self.display_name} ")
    end
  end
  def owner_membership_roles
    [Circle::ADMIN_ROLE]
  end
  
  has_many :owned_circles, :class_name => 'Circle', :foreign_key => :owner_id, :dependent => :nullify
  
  # A user has many memberships to various circles.
  has_many :memberships, :dependent => :destroy
  accepts_nested_attributes_for :memberships, :allow_destroy => true
  
  # A user is a member of many circles through memberships
  
  # Circles
  has_many :circles, :through => :memberships, :source => :circle    
  has_many :my_circles, :through=>:memberships, :source=>:circle, :conditions=>"roles ~ '- #{Circle::ADMIN_ROLE}'"
  
  # This method should be used to create fileter for SQL statement so that I can cache the circle list
  # since it will not change very often for a user.
  def circles_id
    (circles.collect{|c| c.id}).to_s.delete("[]")
  end
  
  # Family
  has_many :families, :through=>:memberships, :source=>:circle_source, :source_type=>'Family'
  has_many :my_families, :through=>:memberships, :source=>:circle_source, :source_type=>'Family', :conditions=>"roles ~ '- #{Circle::ADMIN_ROLE}'"
  has_many :family_memberships, :class_name => 'Membership', :conditions=>{:circle_source_type=>'Family'}
  has_one :family, :through=>:memberships, :source=>:circle_source, :source_type=>'Family', :conditions=>"roles ~ '- #{Family::MY_FAMILY}'"
  
  # Classrooms
  has_many :classrooms, :through => :memberships, :source=>:circle_source, :source_type=>'Classroom'   
  has_many :my_classrooms, :through=>:memberships, :source=>:circle_source, :source_type=>'Classroom', :conditions=>"roles ~ '- #{Circle::ADMIN_ROLE}'"
  has_many :classroom_memberships, :class_name => 'Membership', :conditions=>{:circle_source_type=>'Classroom'}
  accepts_nested_attributes_for :classroom_memberships, :allow_destroy => true
   
  # Schools 
  has_many :schools, :through => :memberships, :source=>:circle_source, :source_type=>'School'
  has_many :my_schools, :through=>:memberships, :source=>:circle_source, :source_type=>'School', :conditions=>"roles ~ '- #{Circle::ADMIN_ROLE}'"
  
  # Groups
  has_many :groups, :through => :memberships, :source=>:circle_source, :source_type=>'Group'
  has_many :my_groups, :through=>:memberships, :source=>:circle_source, :source_type=>'Group', :conditions=>"roles ~ '- #{Circle::ADMIN_ROLE}'"
   
   
  # Authentications allows to use third party service credentials to signup/in to the School Circle.
  has_many :authentications, :dependent => :destroy
  
  # Sent Invitations  
  has_many :invitations, :foreign_key => :inviter_id, :dependent => :destroy 
  
  # Authored posts: messages, reminders, ...
  has_many :sent_posts, :class_name => 'Post', :foreign_key => :sender_id, :dependent => :nullify
  
  # Uploaded files      
  has_many :zfiles

  # Authored comments
  has_many :comments, :dependent=>:destroy
  
  # Accessible attributes for your model, this is particularly important for
  # supporting nested forms. So be really careful if you edit this.
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :profile_attributes, :classroom_memberships_attributes, :memberships_attributes
  
  # A user can votes on posts and comments
  acts_as_voter
  
  # Syntax sugar 
  delegate :full_name, :first_name, :last_name, :sex, :birthday, :time_zone, :language, :locale, :to=>:profile, :allow_nil=>true, :prefix=>true
  
  
  # This method is a hook that the Devise:RegistrationsController uses to
  # give resources the opportunity to get builded by using data stored in the
  # session.
  #
  # Details:
  #   new_with_session is called by the Devise::RegistrationsController
  # build_resource method.
  # Making the user :registrable does 2 things: first it creates the various
  # user/registrations routes, second it add the new_with_session method to
  # the User class. Since I do not want the routes created by :registerable
  # but I want to use the implementation of the build_resource method of the
  # Devise:RegistrationsController at the minimum I have to provide the basic
  # implementation like this:
  #
  #   def new_with_session(params, session)
  #       user = User.new(params)
  #   end
  #
  #  Well but I also want to support registration of user with incomplete info
  #  coming from other service (Facebook, Twitter, etc. ) account.
  #  Here is the scenario: a user uses twitter to sign in but his info in twitter
  #  does not provide a sex or a birthday information therefore the school circle
  #  cannot complete the registration since for each user is necessary to knwo
  #  sex and birthday. So I want to use to be redirected to the standard sign up
  #  page but some fields of the form will be already filled up with the info
  #  we got from the Twitter account.
  #
  #  See:
  #    - devise source code
  #    - omniauth_callbacks_controller code

  # Build a user using information from params and stored in the session.
  def self.new_with_session(params, session)
    user = User.new(params)
    if registration_hash=session['registration_hash']
      user.apply_user_and_profile_info_from_registration_hash(registration_hash)
    end
    user
  end

  def self.create_user(registration_hash)
    logger.info "Creating new user with registration hash: #{registration_hash.to_yaml}"
    unless registration_hash or resigration_hash.empty?
      return nil
    end
    user = User.new
    user.email = registration_hash[:email]
    if registration_hash[:password]
      user.password = registration_hash[:password]
    else
      user.password = Devise.friendly_token[0,20]
    end
    user.password_confirmation = user.password
    # call this before saving the user so that the profile firs_name and last_name are set and they
    # are used to name the personal circle.
    user.apply_user_and_profile_info_from_registration_hash(registration_hash)
     
    if registration_hash[:skip_confirmation] == true
      user.confirm!
    end
    
    unless user.save
      logger.error(user.errors)
      return user
    end
    
    if registration_hash[:memberships]
      registration_hash[:memberships].each do |m|
        user.memberships << Membership.new(:circle_id => m[:circle_id], :roles => m[:roles])
        logger.debug("User #{user.username} is now member of circle #{m[:circle_id]} with roles #{m[:roles].to_s}")
      end
    end
    logger.info("Added new user #{user.username} with profile: #{user.profile.inspect}")
    user    
  end

  def self.create_child(user_attributes)
    child = User.new(user_attributes)
    child.assign_child_email
    child.password = Devise.friendly_token[0,20]
    child.confirmed_at = Time.now
    child.profile.when_confirmed=Time.now
    child.save!
    child
  end
  
  def subscribed_family_circles
     memberships.collect {|m| m.circle if m.circle.is_family?}
  end
  
  def postable_circles
    postable_circles=[]
    memberships.each do |m|
      intersection = (m.roles & [Membership::ADMIN_ROLE, Membership::USER_ROLE])
      if (intersection.count > 0)
        postable_circles.push(m.circle)
      end
    end
    postable_circles
  end
  
  def reminders(circles_filter=nil)
    circles_filter=circles_filter || self.circles 
    Post.where(
        "type=:type AND ((circle_id IN (:circles) AND receiver_id IS NULL) OR (circle_id IS NULL AND receiver_id=:user_id)) ", 
        :type=>"Reminder",
        :circles=>circles_filter,
        :user_id=>self.id)
  end
  
  def feed_items(circles_filter=nil)
     circles_filter=(circles_filter || self.circles.collect{|c| c.id}.compact ).to_s.delete("[]")
     Post.find_by_sql(%Q{
          SELECT *
          FROM (                                                                  
                  select *, rank() over (partition by thread_id order by created_at DESC)
                  from posts
                  where circle_id IN (#{circles_filter}) OR (receiver_id=#{self.id})
                ) as dt
           WHERE rank = 1
           ORDER BY created_at DESC })
  end
  
  #TODO :use hash as input parameters
  # circles_filter must be an array of circles id
  def feed_items_paginate(circles_filter=nil, page, per_page)
    circles_filter=(circles_filter || self.circles.collect{|c| c.id}.compact ).to_s.delete("[]")
    Post.paginate_by_sql(%Q{
        SELECT *
        FROM (                                                                  
                select *, rank() over (partition by thread_id order by created_at DESC)
                from posts
                where circle_id IN (#{circles_filter}) OR (receiver_id=#{self.id})
              ) as dt
         WHERE rank = 1
         ORDER BY created_at DESC }, :page=>page, :per_page=>per_page)      
  end
  
  def my_family
    family_memberships.each do |m|
      logger.info("#{m.circle_source}")
      if (m.roles.include? Family::MY_FAMILY)
         return m.circle_source
      end
    end
    return nil
  end

  def neighbours
    # TODO: optimize me.
    neighbors = Set[]
    circles.each do |c|
      c.members.each do |m|
        neighbors << m  if m.profile.is_not_child?
      end
    end
    neighbors.to_a.sort {|a,b| a.profile_full_name.downcase <=> b.profile_full_name.downcase  }
  end
  
  # This method takes a registration hash and applies it to a user. The registration hash
  # is a hash that describes the user and its profile.
  # This is an extension of the build method of the User class therefore DO NOT put in here 
  # any code that assumes the user object has been saved to the db. (For instance adding memberships
  # to an unsaved user will not work because a valid membership need a user_id which is not set if 
  # the user object is not saved).
  def apply_user_and_profile_info_from_registration_hash(registration_hash)
    logger.info("Appying the following registration hash to user #{self.username}: #{registration_hash.to_s}")
    self.email = registration_hash[:email] if self.email.blank?
    if registration_hash[:skip_confirmation]
      self.skip_confirmation!
    end
    if self.profile
      if registration_hash[:profile_attributes]
        registration_hash[:profile_attributes].each do |name, value|
          if name.to_s == "location"
            self.profile.location = Location.create(:input_string=>value)  
          else
            self.profile.send("#{name}=", value)
          end
        end
        logger.error(self.profile.errors) unless self.profile.valid?  
      end
    end    
  end

  # This allows the user to save changes to its account without having to enter a password.
  # However if te user wants to update his password it has to enter the current password.
  def update_with_password(params={})
    current_password = nil;

    # if the user leaves the :password field blank than he does NOT want to update
    # his current password so removes the filed from the form and pass update the model.
    if params[:password].blank?
      params.delete(:current_password)
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    else
      current_password = params.delete(:current_password)
    end

    result = nil
    # if the user has set :current_password than we assumes he wants to update his password
    # so check that the :current_password is valid. Also this is to support forms that requires
    # the user to enter is password before making any changes.
    if current_password
      if valid_password?(current_password)
        result = update_attributes(params)
      else
        self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
        self.attributes = params
        result = false
      end
    else
      result = update_attributes(params)
    end

    clean_up_passwords
    result
  end

  def accept_invitation(invitation)
     self.memberships << invitation.memberships
     invitation.is_used=true
     invitation.save!
  end
  
  def has_user_membership_for?(circle)
    if not circle.is_a? Circle
      raise "circle must be a Circle!"
    end 
    has_role?(Circle::USER_ROLE, circle)
  end
  
  def has_admin_membership_for?(circle)
    if not circle.is_a? Circle
      raise "circle must be a Circle!"
    end 
    has_role?(Circle::ADMIN_ROLE, circle)
  end
  
  def has_role?(role_name,object)
    raise "role_name cannot be blank" if role_name.blank?
    raise "object cannot be blank" if object.blank?
    if object.is_a? Circle
      mc = memberships.where(:circle_id=>object.id)
      case role_name
      when Membership::USER_ROLE
        a = mc.collect{|m| m if ((m.roles & [Circle::ADMIN_ROLE, Circle::USER_ROLE]).count > 0 )}.compact
        return (a.count > 0)
      when Membership::ADMIN_ROLE
        a = mc.collect {|m| m if ((m.roles & [Circle::ADMIN_ROLE]).count > 0 )}.compact
        return (a.count > 0)
      else
        return false
      end
    else
      return false
    end
  end

  def is_child?
    email.split("@")[1]=="kids.#{Theschoolcircle::Application.config.official_domain}"
  end
  
  def is_parent?
    profile.is_parent?
  end
  
  def parents
    if is_child? and my_family
      my_family.adults
    else
      []
    end
  end
  
  def children
    if is_parent? and my_family
      my_family.children
    else
      []
    end
  end
  
  def about
    self.profile.about
  end
  
  def avatar_url(a)
    profile.avatar_url(a)
  end
  
  def assign_child_email
    full_name = self.profile.full_name.delete(' ')
    if full_name.blank?
      return nil
    end
    users_with_similar_email = User.find(:all, :conditions => ['email LIKE ?', "#{full_name}" +'%' ])
    canditate_email = "#{full_name}@kids.#{Theschoolcircle::Application.config.official_domain}".downcase
    i = 1
    until (users_with_similar_email.select{|u| u.email.downcase == canditate_email.downcase}).empty? do
      canditate_email = "#{full_name}_#{i}@kids.#{Theschoolcircle::Application.config.official_domain}".downcase
      i += 1
    end
    self.email = canditate_email
  end
  
  
  private
  def create_profile
    self.build_profile if profile.nil?
  end
  # user name is case insensitive!
  def set_username
    if self.username.blank?
      first_candidate_username = self.email.split("@")[0]
      candidate_username = first_candidate_username.downcase
      users_with_similar_username = User.where("username ~* ?", "#{candidate_username}")
      i = 1
      until (users_with_similar_username.select{|u| u.username.downcase == candidate_username}).empty? do
        candidate_username = "#{first_candidate_username}_#{i}"
        i += 1
      end
      self.username = candidate_username
    end
  end
  def check_confirmation_bypass
    return nil if self.email.nil?
    if self.email.include?('<>') 
      self.email = self.email.gsub("<>","")
      skip_confirmation!
    end
    if self.email.start_with?('+')
      self.email = self.email[1..-1]
      skip_confirmation!
    end
  end
  def destroy_classrooms_and_schools_memberships
    return unless profile.is_child?
    m=Membership.where('user_id = ? AND (circle_source_type LIKE ? OR circle_source_type LIKE ?)', id, "Classroom", "School")
    m.each do |membership|
      membership.destroy
    end  
  end
  def set_auth_token
     reset_authentication_token if authentication_token.nil?
  end
      
end


