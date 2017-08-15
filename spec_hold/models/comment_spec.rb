require 'spec_helper'


describe Comment do
  
  let(:comment) { Factory(:comment) }
  
  it "is valid with valid attributes" do
    comment.should be_valid
  end
  
  it "is not valid if content is less than 3 chars" do
    comment.comment='a'*2
    comment.should_not be_valid
  end
  
  it "is not valid if content is longer than 400 chars" do
    comment.comment='a'*401
    comment.should_not be_valid
  end
  
  it "is not valid without a user" do
    comment.user=nil
    comment.should_not be_valid
  end
  
  it "is not valid without a commentable" do
    comment.commentable=nil
    comment.should_not be_valid
  end
  
  
  
  
end