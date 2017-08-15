require 'active_record'


module ActsAsCircleSource

  def self.included(base)
    base.extend ClassMethods  # add the ClassMethods to the including class 
  end

  module ClassMethods
    
    CIRCLE_SOURCE_NAME_REGEX = /^[\w\s\-\']+$/i
    
    def acts_as_circle_source
      after_initialize :set_defaults
      after_save :set_up_circle

      belongs_to :user                       
      validates :user, :presence => true

      validates :name,:length=>{ :maximum=>200 }, :format=>{ :with=>CIRCLE_SOURCE_NAME_REGEX }

      has_one :circle, :as => :source, :dependent=>:destroy
      include InstanceMethods      
    end
      
  end

  module InstanceMethods
    
    def set_defaults
      self.name = "#{self.user.profile_full_name}'s #{self.circle_source_type}" if self.name.blank? && self.user
    end
 
    def circle_default_name
      if self.name.index /circle/i 
        "#{self.name}"
      else
        "#{self.name} Circle"      
      end      
    end

    def circle_description
      "This is a circle"
    end
    
    # the circle source type is typically the name of the class of the circle source, like "Classroom", "School", "User", etc.
    # in some cases the circle source class will want to override that like in the case of the "Group" class since we do not
    # want to see the name Group in names. In those cases the  circle source class needs to override the my_circle_source_type
    # method. 
    def circle_source_type
      type = self.my_circle_source_type ||  self.class.name
    end
    
    def my_circle_source_type
      nil
    end
    
    def set_up_circle
      if self.circle.nil?
        self.circle = Circle.new(:name=>circle_default_name, :source=>self, :owner=>self.user, :description=>circle_description)
      end
    end

    def name=(value)
       if value.blank?
         super(value)
       else
         write_attribute(:name, value)
         if self.circle
           self.circle.name = (value.index(/#{self.class.name}/io) ? value : "#{value} #{self.class.name}".strip)
         end
       end
     end 
     
    def display_name
      if self.name.downcase.include? self.circle_source_type.downcase
        self.name
      else
        "#{self.name} #{self.circle_source_type.downcase}"
      end       
    end
    
    def short_name
      self.name.gsub(/#{self.circle_source_type.downcase}/io,'')
    end
    
    def user_membership(attributes={})
      a = attributes.merge({:circle=>circle, :roles=>([Circle::USER_ROLE]+(attributes[:roles] || []))})
      Membership.new a
    end
  
    def admin_membership(attributes={})
      a = attributes.merge({:circle=>circle, :roles=>([Circle::USER_ROLE]+(attributes[:roles] || []))})
      Membership.new a
    end
   
    def default_membership(attributes={})
      user_membership(attributes)
    end
      
    def owner_membership_roles
      [Circle::ADMIN_ROLE] 
    end
   
    def add_user(user)
      user_membership(:user=>user).save!
    end
        
    def add_admin(user)
      admin_membership(user).save!
    end
       
  end

end