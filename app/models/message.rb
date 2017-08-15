class Message < Post
  
  MAX_ATTACHMENTS = 5
  MAX_ATTACHMENT_SIZE = 2.megabyte
  MESSAGE_REPLY_TO_SENDER='sender'    
  MESSAGE_REPLY_TO_CIRCLE='circle'
      
  before_save :ensure_title_not_blank, :set_posted_at
  after_save :link_with_zfiles
  after_save :sync_library_items
  
  attr_accessor :file_ids
  
  has_many :zfiles, :as=>:attachable, :dependent=>:destroy
  accepts_nested_attributes_for :zfiles, :allow_destroy=>true
  validate :validate_attachments
  
  acts_as_commentable
  
  validates :content, :length=>{:minimum=>0, :maximum=>30000}
  validates_with MessageReceiverValidator
  
  def score
    upvotes.count-downvotes.count
  end
  
  # It create a new instance of a message that is a reply for self. The returned
  # message DOES NOT have the sender assigned.
  def new_reply(to=MESSAGE_REPLY_TO_SENDER, sender)
    if to!=MESSAGE_REPLY_TO_SENDER and to!=MESSAGE_REPLY_TO_CIRCLE
      raise "wrong value for to parameter"
    end
    if sender.blank?
      raise "must specify message sender"
    end
    
    # set the receiver
    receiver_id = nil
    circle_id = nil
    if to === MESSAGE_REPLY_TO_CIRCLE
      circle_id = self.circle_id
    else
      receiver_id = self.sender_id
    end
        
    # set the title
    title = self.title
    if title =~ /^Re:|^Re\(\d+\):/
      title = "#{self.title}"
    else
      title = "Re: #{self.title}"
    end
    
    #set the content
    sent_at = self.created_at.strftime(I18n.t('time.formats.long'))
    content = "<p>&nbsp</p><p></p>---------------------------------------------------------------------------<p>&nbsp</p>"+
              "<p><strong>From:</strong> #{self.sender.profile_full_name}</p>"+
              "<p><strong>To:</strong> #{self.circle_id ? self.circle.display_name : User.find(self.receiver_id).profile_full_name}</p>"+
              "<p><strong>Sent:</strong> #{sent_at}</p><p></p>"+
              "#{self.content}" 
    
    reply = Message.new(:sender=>sender, :title=>title, :receiver_id=>receiver_id, :circle_id=>circle_id, :content=>content, :parent_id=>self.id, :thread_id=>(self.thread_id || self.id)) 
  end
  
  
  private
  def set_posted_at
    self.posted_at=Time.now
  end
  def ensure_title_not_blank
     if self.title.blank? 
       self.title="Untitled"
     end
  end
  def validate_attachments
    errors.add_to_base("Too many attachments - maximum is #{MAX_ATTACHMENTS}") if zfiles.length > MAX_ATTACHMENTS
    zfiles.each {|a| errors.add_to_base("#{a.name} is over #{MAX_ATTACHMENT_SIZE/1.megabyte}MB") if a.asset_file_size > MAX_ATTACHMENT_SIZE}
  end
  def link_with_zfiles
    return unless (zfile_ids && zfile_ids.is_a?(Array))    
    zfile_ids.each do |id|
      zfile = Zfile.find(id)
      if zfile
        if zfile.user_id==sender_id
          zfile.attachable = self
          zfile.save!
        else
          logger.error("Could not attach zfile #{id} to message #{self.id}. User ids do not match.")
        end
      end
    end
  end
  def sync_library_items
    if posted_at_changed? && posted_at_was.nil? && posted_at && zfiles.count > 0
      # posted at is nil or has the date it was posted and that is it!
      zfiles.each do |d|
        if d.is_doc?
          Document.create(:file_id=>d.id, :circle_id=>(circle_id || User.find(:receiver_id).personal_circle.id), :source_id=>self.id, :source_type=>self.class.name) 
        end
      end    
    end
  end
  
  
end