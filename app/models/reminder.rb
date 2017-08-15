class Reminder < Post
  after_initialize :set_content_type
  validates :content, :length=>{ :minimum=>4, :maximum=>140 }   
  validates :circle_id, :presence=>true
  
  private
  def set_content_type
    self.content_type = "text/plain"
  end
end
