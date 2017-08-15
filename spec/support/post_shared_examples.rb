require 'spec_helper'
require 'set'
  
shared_examples_for "a post" do

    let(:post) { Factory(:post) }

    it "is valid with valid attributes" do
      post.should be_valid
      post.should be_valid
    end

    it "is not valid without a sender" do
      post.sender  = nil
      post.should_not be_valid
    end

    it "is valid with content that is an empty string" do
      post.content = ""
      post.should be_valid
    end

    it "is not valid with a blank type" do
      post.type    = ""
      post.should_not be_valid
      post.type    = nil
      post.should_not be_valid
    end
    
end
