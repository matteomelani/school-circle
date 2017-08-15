class Profile < ActiveRecord::Base
  
  AVAILABLE_LOCALE = [ {:locale=>:en, :language => "English"} ]
  DEFAULT_TIME_ZONE = "Pacific Time (US & Canada)"
  FIRST_AND_LAST_NAME_REGEX = /\A[a-zA-Z]+\z/i
  BIRTHDAY_VALID_RANGE = ((Time.now-110.years).to_datetime)...(Time.now.to_datetime)
  URL_REGEX = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
  
  CHILD='child'
  PARENT='parent'
  TEACHER='teacher'
  enum_attr :main_role, [PARENT, TEACHER, CHILD]
  enum_attr :sex, %w(male female)

  serialize :contacts, Array

  after_initialize :set_default_values
  
  validates :first_name, :last_name, :presence=>true, :length => { :maximum => 30 }, :format=>{ :with => FIRST_AND_LAST_NAME_REGEX }
  validates :sex, :allow_nil => true, :allow_blank => true, :inclusion => {:in => [:male,:female]}
  validates :main_role, :allow_nil => true, :allow_blank => true, :inclusion => {:in => [:teacher,:parent,:child]}
  validates :birthday, :allow_nil => true, :allow_blank =>true, :inclusion => BIRTHDAY_VALID_RANGE
  
  with_options :if => :is_child? do |p|
    p.validates :sex, :inclusion=>{:in => [:male,:female], :message=>"gender must be selected"}
  end
    
  # A profile belongs to a user   
  belongs_to :user

  # A profile has many phone number for now we support only 3: Mobile, Home and Work
  has_many :phone_numbers, :as=>:owner, :dependent=>:destroy
  accepts_nested_attributes_for :phone_numbers, :allow_destroy=>true, :reject_if=>proc { |attributes| attributes['number'].blank? }
  
  has_one :location, :as=>:locationable, :dependent=>:destroy
  accepts_nested_attributes_for :location, :allow_destroy=>true, :reject_if=>proc { |attributes| attributes['input_string'].blank? }
    
  # A profile has one and only one avatar
  include HasAvatar
  has_avatar
  def default_avatar_url
    "user_original.png"   
  end
  
    
  attr_accessible  :first_name, :last_name, :sex, :birthday, :time_zone, :phone_numbers_attributes, :location_attributes, :locale, 
                   :when_confirmed, :main_role, :about, :avatar
  
  
  # Returns true if the the profile was reviewed and saved by the user.
  def confirmed?
    self.when_confirmed
  end
  
  # Override standard setter to capitalize first name
  def first_name=(value)
    write_attribute(:first_name, (value ? value.capitalize: value))
  end

  # Override standard setter to capitalize last name  
  def last_name=(value)
    write_attribute(:last_name,  (value ? value.capitalize: value))
  end
  
  # Returns the first and last name of the user separated by a space.
  def full_name
      "#{first_name} #{last_name}".rstrip
  end

  # TODO: What do I use this methods for??
  def language
    current_locale = I18n.locale 
    if  current_locale != :"#{self.locale}"
        I18n.locale = :"#{self.locale}"
    end
       lan = I18n.translate("language")
       I18n.locale = current_locale
       return lan  
  end

  def mobile
    get_phone_number_by_name("mobile")
  end
  
  def work
    get_phone_number_by_name("work")
  end
  
  def home
    get_phone_number_by_name("home")
  end
    
  
  private
  def get_phone_number_by_name(label)
    return nil if label.blank?
    if phone_numbers
      ms = phone_numbers.select{|pn| pn && pn.name.downcase=="#{label}"}
      ms.first
    end  
  end
  def set_default_values
    self.sex = nil if self.sex.blank?
    self.main_role = nil if self.main_role.blank?
    self.time_zone = DEFAULT_TIME_ZONE if self.time_zone.blank?
    self.locale = "en" if self.locale.blank?
    self.when_confirmed = nil if self.when_confirmed.blank?
    self.contacts = self.contacts || []
  end
  
end