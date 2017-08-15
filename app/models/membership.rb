class Membership < ActiveRecord::Base
  
  after_initialize :init_roles
  after_save :set_circle_source, :create_parent_circle_membership, :create_user_parent_membership
  before_destroy :destroy_parent_circle_membership, :destroy_user_parent_membership
  
  ADMIN_ROLE  = "admin"
  POSTER_ROLE = "poster"
  READER_ROLE = "reader"
  USER_ROLE   = "user"  # user can read and write posts but cannot admin memberships or circle properties 
  ROLES_VALUES = []
  ROLES_VALUES << ADMIN_ROLE
  ROLES_VALUES << USER_ROLE
    
  DEFAULT_ROLES = [ USER_ROLE ]
   
  serialize :roles, Array
  serialize :privacy_settings, Hash
  
  belongs_to :circle
  belongs_to :circle_source, :polymorphic=>true
  belongs_to :user
  
  validates :circle_id, :presence => true
  # a user id is not required otherwise creating child user with nested attributes fails.
  validates :user_id, :uniqueness => {:scope => :circle_id, :message => I18n.t("activerecord.errors.membership.one_memebership_per_circle")}
  
  # Followng code is not in used for now.
  #
  # def can_read?(principal_role, info)
  #      can?(principal_role, "read", info)
  #   end
  #   
  # def can?(principal_role, action, info)
  #     raise "Action #{action} not supported" if action != "read"
  #     return true unless Circle.roles.include? principal_role
  #   
  #     # the privacy settings know nothing about this info so action is permitted
  #     return true if privacy_settings[info].nil?
  #     can_read = 1 
  #     i = principal_role==Circle::ADMIN_ROLE ? 0 : 1 
  #     if privacy_settings[info][i] > 0
  #       true
  #     else
  #       false
  #     end    
  #   end
  
  private
  def init_roles
    self.roles = DEFAULT_ROLES if self.roles.empty?
  end
  def set_circle_source
    if ( circle.source_id != read_attribute(:circle_source_id) or circle.source_type!=read_attribute(:circle_source_type) )
      write_attribute(:circle_source_id, circle.source_id)
      write_attribute(:circle_source_type, circle.source_type)
      save!
    end
  end
  # This method looks at the circle and its source, 
  #    if circle is classroom and classroom has a verified school
  #      then the user also gets a membership to the school
  def create_parent_circle_membership
    if (circle.source_type.downcase=="classroom" and circle.source.school and circle.source.is_verified? and Membership.where(:user_id=>self.user.id, :circle_id=>circle.source.school.circle.id).empty? )
      school_membership = Membership.new(:user=>self.user, :circle=>circle.source.school.circle)
      school_membership.save!
    end
  end  
  def destroy_parent_circle_membership
    if circle.source_type.downcase=="classroom" and circle.source.school
      ms = Membership.where(:user_id=>self.user.id, :circle_id=>circle.source.school.circle.id)
      ms.first.destroy if ms.count>0
    end
  end
  # if is child user makes sure the parents have the same membership
  def create_user_parent_membership
    # if the membership user is not a child or if the membership is to the personal circle then do nothing
    if  !user.is_child? or circle==user.personal_circle 
      return
    end
    
    user.parents.each do |parent|
      Membership.find_or_create_by_user_id_and_circle_id(:user_id=>parent.id, :circle_id=>circle_id)
    end
  end
  def destroy_user_parent_membership
    #TODO: optimize this method as right now is inefficient
    if user.is_child? and (circle_source.is_a?(Classroom) or circle_source.is_a?(School) or circle_source.is_a?(User))
      self.user.parents.each do |parent|
        # find the parent membership to this circle
        parent_membership = Membership.where(:user_id=>parent.id, :circle_id=>circle_id)
        next if parent_membership.empty?
        delete_membership = true        
        # any other children of this parent are member of this circle?
        parent.my_family.children.each do |child|
          next if child==self.user
          # if a child of the parent is a member of the same circle than do not delete the membership
          if Membership.where(:user_id=>child.id, :circle_id=>circle.id).count>0 
            delete_membership = false
            break
          end
        end
        parent_membership.first.destroy if delete_membership
      end
    end
  end

end
