class Comment < ActiveRecord::Base

  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true

  default_scope :order => 'created_at ASC'

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  # NOTE: Comments belong to a user
  belongs_to :user
  
  validates :comment,
           :length=>{:minimum=>3, :maximum=>400}
  validates :user_id,
            :presence=>true
  validates :commentable,
            :presence=>true
  
  acts_as_votable
  
end
