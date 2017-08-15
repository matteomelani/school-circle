class Post < ActiveRecord::Base
  serialize :data_bag, Hash
  
  
  # receiver_id is to be used when a post is directed to a user not a circle. In this case circle_id should be blank.
  attr_accessible :title, :content, :sender_id, :sender, :receiver_id, :receiver, :circle_id, :zfiles, :zfiles_attributes, 
                  :parent_id, # if this post is a reply to another post this field contains the id of that post
                  :thread_id  # this is define the thread, it always point to the first message of a thread
  
  after_save :set_thread_id
  belongs_to :circle
  belongs_to :sender, :class_name => 'User'
  
  validates :sender_id, :type, :presence => true
  
  default_scope :order => 'posts.created_at DESC'
  
  # NOTE: acts_as_votable cannot handle votable that are in a STI therefore I used
  # the fork https://github.com/jbgutierrez/acts_as_votable that has a small fix
  # that makes the gem work as long as the votable is the base class.
  acts_as_votable

  def to 
    if circle
      circle.source
    else
      User.find(receiver_id)
    end
  end
  
  def thread_posts
    Post.where(:thread_id=>thread_id).order("created_at DESC")
  end
  
  
  # filters
  scope :to_circles, lambda { |circles| where('circle_id IN (?) AND receiver_id IS NULL', circles) } 
  scope :to_user, lambda { |user| where('receiver_id=? AND circle_id IS NULL', user.id) }
  
  def self.filter_by_circles_collapse_threads_and_paginate(circles, page, per_page)
    circles_filter = circles.collect { |c| (c.is_a?(Circle) ? c.id : c) }.compact.to_s.delete("[]")
    if Theschoolcircle::Application.config.db_version == "8.3" 
      Post.paginate_by_sql(%Q{
        SELECT p.*
        FROM (                                                                  
               select x.thread_id, max(x.created_at) as maxdt
               from posts x
               where x.circle_id IN (#{circles_filter})
               group by x.thread_id
             ) as dt
       INNER JOIN posts p ON p.thread_id = dt.thread_id and p.created_at = dt.maxdt
       ORDER BY p.created_at DESC}, :page=>page, :per_page=>per_page)
    else    
      Post.paginate_by_sql(%Q{
          SELECT *
          FROM (                                                                  
                  select *, rank() over (partition by thread_id order by created_at DESC)
                  from posts
                  where circle_id IN (#{circles_filter})
                ) as dt
           WHERE rank = 1
           ORDER BY created_at DESC }, :page=>page, :per_page=>per_page)      
    end
  end
  
  def self.filter_by_to_user_collapse_threads_and_paginate(user, page, per_page)
    if Theschoolcircle::Application.config.db_version == "8.3" 
      Post.paginate_by_sql(%Q{
        SELECT p.*
        FROM (                                                                  
               SELECT x.thread_id, max(x.created_at) as maxdt
               FROM posts x
               WHERE x.receiver_id=#{user.id}
               GROUP BY x.thread_id
             ) as dt
       INNER JOIN posts p ON p.thread_id = dt.thread_id and p.created_at = dt.maxdt
       ORDER BY p.created_at DESC}, :page=>page, :per_page=>per_page)
    else
      Post.paginate_by_sql(%Q{
          SELECT *
          FROM (                                                                  
                  select *, rank() over (partition by thread_id order by created_at DESC)
                  from posts
                  where receiver_id=#{user.id}
                ) as dt
           WHERE rank = 1
           ORDER BY created_at DESC }, :page=>page, :per_page=>per_page)      
    end
  end
  
  def self.all_for_user_collapse_threads_and_paginate(user, page, per_page)
    circles_filter = (user.circles.collect{|c| c.id}).to_s.delete("[]")
    if Theschoolcircle::Application.config.db_version == "8.3" 
      Post.paginate_by_sql(%Q{
        SELECT p.*
        FROM (                                                                  
               select x.thread_id, max(x.created_at) as maxdt
               from posts x
               where x.circle_id IN (#{circles_filter}) OR (x.receiver_id=#{user.id})
               group by x.thread_id
             ) as dt
       INNER JOIN posts p ON p.thread_id = dt.thread_id and p.created_at = dt.maxdt
       ORDER BY p.created_at DESC}, :page=>page, :per_page=>per_page)
    else   
      Post.paginate_by_sql(%Q{
        SELECT *
        FROM (                                                                  
                select *, rank() over (partition by thread_id order by created_at DESC)
                from posts
                where circle_id IN (#{circles_filter}) OR (receiver_id=#{user.id})
              ) as dt
         WHERE rank = 1
         ORDER BY created_at DESC }, :page=>page, :per_page=>per_page)
    end      
  end
  
  private
  # thread id gets set so that it is easier to work with the SQL to generate the feeds,
  # see the User.feed_items method.
  def set_thread_id
    if read_attribute(:thread_id).nil? 
      write_attribute(:thread_id, self.id)
      save!
    end
  end
  
end

