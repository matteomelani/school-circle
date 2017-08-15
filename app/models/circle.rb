class Circle < ActiveRecord::Base
  
  Circle::ADMIN_ROLE=Membership::ADMIN_ROLE
  Circle::USER_ROLE=Membership::USER_ROLE
  Circle::ROLES=[Circle::ADMIN_ROLE, Circle::USER_ROLE]
    
  before_save :set_random_name, :set_pin
  after_save :create_owner_membership
    
  validates :name, :presence => true, :length => { :within => 0..200}
  validates :random_name, :uniqueness => true
  validates :description, :allow_blank=>true, :length=>{ :within => 0..1000}
  
  # A circle has one and only one owner
  belongs_to :owner, :class_name => 'User'
  validates :owner_id, :presence => true

  # A circle has one and only one source object that can be a user, class, school or family
  belongs_to :source, :polymorphic => true           
  validates :source_id, :source_type, :presence => true
  
  # A circle has many memberships and members
  has_many :memberships, :dependent=>:destroy
  has_many :members, :through=>:memberships, :source =>:user
 
  # A circle has many postsm they can be of various types: message, reminders, etc.
  has_many :posts, :dependent=>:destroy, :order=>'created_at DESC'
  
  # A circle has many invitations that the circle members extends to other users.
  has_many :invitations, :dependent=>:destroy, :order=>'created_at ASC'
  
  def Circle.roles
    Circle::ROLES
  end
             
  def kind
    source_type.to_s.downcase
  end
  
  def stats
    #{:members_count => memberships.count, :messages_count => posts.count, :reminders_count => reminders.count }
  end
  
  def email
   "#{self.random_name}@post.#{Theschoolcircle::Application.config.app_domain}"
  end
      
  def display_name
    if self.name.downcase.include? "circle"
      self.name
    else
      "#{self.name} Circle"
    end
  end
  
  # true if this is a family circle
  def is_family?
    self.source_type.downcase==Family.name.downcase
  end
  
  # true if this is a classroom circle  
  def is_classroom?
    self.source_type.downcase==Classroom.name.downcase
  end
  
  # true if this is a user (or personal) circle
  def is_user?
    self.source_type.downcase==User.name.downcase
  end
  
  # true if this is a school circle
  def is_school?
    self.source_type.downcase==School.name.downcase
  end
  
  def admins
    memberships.collect {|m| m.user if ((m.roles & [Membership::ADMIN_ROLE]).count > 0 )}.compact
  end
  
  def users
    memberships.collect {|m| m.user if ((m.roles & [Membership::ADMIN_ROLE, Membership::USER_ROLE]).count > 0 )}.compact
  end
  
  def feed_items(page,per_page)
    Post.paginate_by_sql(%Q{
        SELECT *
        FROM (                                                                  
                select *, rank() over (partition by thread_id order by created_at desc)
                from posts
                where circle_id= (#{self.id})
              ) as dt
         WHERE rank = 1}, :page=>page, :per_page=>per_page)
  end

  #TODO: hasavatar is a property of all the circle sources
  def avatar_url(size=:medium)
    if source.is_a? User
      source.profile.avatar_url(size)
    else
      source.avatar_url(size)
    end  
  end
  
  def pending_invitations
     Invitation.where(:circle_id=>id,:is_used=>false)
  end

  def generate_random_name
    words_bag_hash = YAML::load(File.read("#{Rails.root}/config/data/words_bag.yaml"))
    words_bag_hash_loc = words_bag_hash[:en]
    r = Random.new
    adj_list  = words_bag_hash_loc[:adjectives]
    noun_list = words_bag_hash_loc[:nouns]
    adj_index = r.rand(0..adj_list.size)
    n_index = r.rand(0..noun_list.size)
    random_int = r.rand(0..1000)
    "#{adj_list[adj_index]}-#{noun_list[n_index]}-#{random_int}"
   end
  
  
  private
  def create_owner_membership
    unless self.members.include?(self.owner)
      self.memberships.create!(:circle=>self, :user=>self.owner, :roles=>source.owner_membership_roles)
    end
  end
  def set_random_name
    if self.random_name.blank?
      self.random_name = self.generate_random_name
    end  
  end
  def set_pin
    if self.pin.blank?
      r = Random.new
      candidate=""
      loop do
        candidate = (r.rand(0..99999)).to_s
        break if Circle.where(:pin => candidate).empty?
      end
      self.pin = candidate.to_s
    end
  end
  
end
