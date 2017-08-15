require 'spec_helper'

# A Family represent a group of users, the group size is between 2 and 10. A Family is a first class object
# in the School Circle application. 
describe Family do

  #let(:family) { Family.create(:user=>Factory(:user)) }
  let(:family) { Factory(:family) }
  
  it "is valid with valid attributes" do
    family.should be_valid
  end
  
  it "is valid without a location" do
    family.location = nil
    family.should be_valid
  end

  it "is not valid without at least one language" do
    family.languages = nil
    family.should_not be_valid
    family.languages = []
    family.should_not be_valid
  end

  it "has a default language set to the owner's language" do  
    family.languages[0].should == "English"
  end

  it "adds the family creator as an adult member of the family, after the family as been saved" do
    family.circle.members.include?(family.user).should be_true
    family.circle.memberships[0].roles.include?(Family::ADULT_ROLE).should be_true
  end  
  
end


