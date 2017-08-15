module MailerHelpers

  def last_email
    ActionMailer::Base.deliveries.last
  end
  
  def clear_outbox
    ActionMailer::Base.deliveries=[]
  end
  
end

World(MailerHelpers)