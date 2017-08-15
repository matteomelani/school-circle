require 'spec_helper'
require 'support/post_shared_examples.rb'


describe Message do
  it_should_behave_like "a post"
  
  let(:message) { Factory(:message) }
  
  it "is valid with valid attributes" do
    message.should be_valid
  end
  
  it "cannot have more than 5 attachments" do
  end
  
  it "is not valid if attached file are bigger than 2 MB" do
  end
  
  it "is not valid with a blank title" do
  end
  
  it "has the title set to Untitled if the title is not specified" do
    message.title.should == "Untitled"
  end
  
  it "is not valid with content bigger than 30 kilobytes" do
    message.content = 'a' * 30001
    message.should_not be_valid
  end
  
  describe "#new_reply" do
    it "thorws an exception if the argument to is different from #{Message::MESSAGE_REPLY_TO_SENDER} and #{Message::MESSAGE_REPLY_TO_CIRCLE}" do
      u1 = Factory(:user)
      lambda { message.new_reply("", u1) }.should raise_error("wrong value for to parameter")
      lambda { message.new_reply("not right", u1) }.should raise_error("wrong value for to parameter")
    end
    
    it "throws an exception if the sender is not specified" do
      lambda {  message.new_reply(Message::MESSAGE_REPLY_TO_SENDER, nil) }.should raise_error("must specify message sender")
    end
    
    it "creates a new message that is a first reply of this message to the sender" do
      u1 = Factory(:user) 
      reply = message.new_reply(Message::MESSAGE_REPLY_TO_SENDER, u1)
      
      # header
      reply.sender.should == u1
      reply.receiver_id.should == message.sender_id
      reply.circle_id.should == nil
      reply.parent_id.should == message.id
      reply.thread_id.should == message.id
      
      # title & content
      reply.title.should == "Re: #{message.title}"    
      # reply.content = 
    end
    
    it "creates a new message that is a second reply of this message to the sender" do
      u1 = Factory(:user) 
      reply = message.new_reply(Message::MESSAGE_REPLY_TO_SENDER, u1)
      reply.save!
      
      reply_2 = reply.new_reply(Message::MESSAGE_REPLY_TO_SENDER, u1)
      
      # header
      reply_2.sender.should == u1
      reply_2.receiver_id.should == reply.sender_id
      reply_2.circle_id.should == nil
      reply_2.parent_id.should == reply.id
      
      # this is important - make sure thread id is set to the first message - 
      reply.thread_id.should == message.id
      
      # title & content
      reply_2.title.should == "Re: #{message.title}"    
      # reply.content = 
    end
  end
  
  
end