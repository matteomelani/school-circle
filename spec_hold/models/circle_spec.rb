require 'spec_helper'

describe Circle do
  let(:circle) {Factory(:circle)}

  describe "attributes" do

    it "is valid when built with valid attributes" do
      circle.should be_valid
    end

    it "is valid with names that contains all sorts of non-alphanumeric chars" do
      names = ["matteo's circle", "matteo@circle", "matteo@#\$% cirlce"]
      names.each do |n|
        circle.name = n
        circle.should be_valid
      end
    end
    
    it "is NOT valid with a blank name" do
      circle.name = nil
      circle.should_not be_valid
      circle.name = ""
      circle.should_not be_valid
    end

    it "is NOT valid without a owner" do
      circle.owner_id = nil
      circle.should_not be_valid
    end

    it "is NOT valid with names longer than 200 chars" do
      circle.name="a"*201
      circle.should_not be_valid
    end

    it "is NOT valid with a description longer than 1000 chars" do
      circle.description="a"*1001
      circle.should_not be_valid
    end

    it "is NOT valid without a source" do
      circle.source=nil
      circle.should_not be_valid
    end
    
    end

  it "generates a random and unique 5 digit pin number" do
    circle.pin.to_s.size.should <= 5
    circle.pin.to_s.size.should > 0
    circle_code_set = Set.new
    for i in 1..5 do
      cl = Factory(:circle)
      circle_code_set << cl.pin
    end
    circle_code_set.count.should == 5
  end
  
  it "makes its owner a member of the circle" do
    circle.members.where(:id => circle.owner_id).count.should == 1
    circle.memberships.where(:user_id => circle.owner_id)[0].roles.include?(Membership::ADMIN_ROLE)
  end

  describe "#is_family?" do
    it "returns true if the circle is a family circle" do
      f = Factory(:family)
      c = Factory(:circle, :source=>f)
      c.is_family?.should be_true
    end
    
  end

end
