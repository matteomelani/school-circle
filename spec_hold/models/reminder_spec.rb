require 'spec_helper'

describe Reminder do

  let(:reminder) {Factory(:reminder)}
  
  it "is valid with valid attributes" do
    reminder.should be_valid
  end

  it "is not valid without a sender" do
    reminder.sender=nil
    reminder.should_not be_valid
  end
  
  it "is not valid without a circle" do
    reminder.circle=nil
    reminder.should_not be_valid
  end
  
  it "is not valid if the content is longer than 140 characters" do
    reminder.content = 'a'*141
    reminder.should_not be_valid
  end
  
  it "is not valid if the content is shorter than 4 characters" do
    reminder.content = 'a'*3
    reminder.should_not be_valid
  end
  
  it "has the content type set to text/plain" do
    reminder.content_type.should == "text/plain"
  end
  
  # TODO: text should be plain text, not sure how to code this up
  # it "is not valid if the content is NOT plain text" do
  #     reminder.content=""
  #     reminder.should_not be_valid
  #   end
  
end
