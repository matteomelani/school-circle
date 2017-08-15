require 'spec_helper'

describe Membership do
  let(:membership) { Factory(:membership) }

  it "is valid with valid attributes" do
    membership.should be_valid
  end

  it "is not valid without a circle" do
    membership.circle=nil
    membership.should_not be_valid
  end
  
  # A user id is not required otherwise creating child user with nested attributes fails.
  it "is valid without a user" do
     membership.user=nil
     membership.should be_valid
   end
  
  it "has the default roles set to #{Membership::DEFAULT_ROLES}" do
    membership.roles.should =~ Membership::DEFAULT_ROLES
  end
  
  describe 'membership propagation' do
    context "when creating a new classroom membership" do
      it "creates a membership to the classroom's school circle if the classroom has been verified" do
        user1 = Factory(:user)
        school = Factory(:school, :user=>user1)
        classroom = Classroom.create(:user=>user1, :school_association_status=>"verified", :school_id=>school.id)
        
        user2 = Factory(:user)
        classroom_membership = Membership.create(:user_id=>user2.id,:circle_id=>classroom.circle.id)
        classroom.circle.members.include?(user2).should be_true
        classroom.school.circle.members.include?(user2).should be_true
      end
      
      it "does NOT creates a membership to the classroom's' school circle if the classroom has NOT been verified" do
        user1 = Factory(:user)
        school = Factory(:school, :user=>user1)
        classroom = Classroom.create(:user=>user1, :school_association_status=>"unverified", :school_id=>school.id)
        
        user2 = Factory(:user)
        classroom_membership = Membership.create(:user_id=>user2.id,:circle_id=>classroom.circle.id)
        classroom.circle.members.include?(user2).should be_true
        classroom.school.circle.members.include?(user2).should be_false
      end
    end
  end
  
  # can_read? is not used for now
  #
  # describe "#can_read?" do
  #     it "returns true if the role is not in the privacy settings" do
  #       membership.privacy_settings = { "email"=>[0,0] }          
  #       membership.can_read?("immaginarey role", "email").should be_true
  #     end
  # 
  #     it "returns true if the info is not in the privacy settings" do
  #       membership.privacy_settings = { "email"=>[0,0] }        
  #       membership.can_read?(Circle::ADMIN_ROLE, "ippo").should be_true
  #       membership.can_read?(Circle::USER_ROLE, "ippo").should be_true
  #     end
  # 
  #     it "returns true if the role can read the specified membership info" do
  #       membership.privacy_settings = { "email"=>[1,1], "mobile"=>[1,1] }
  #       membership.can_read?(Circle::ADMIN_ROLE, "email").should be_true
  #       membership.can_read?(Circle::USER_ROLE, "email").should be_true     
  #       membership.can_read?(Circle::ADMIN_ROLE, "mobile").should be_true
  #       membership.can_read?(Circle::USER_ROLE, "mobile").should be_true 
  #     end
  # 
  #     it "returns false if the role can not read the specified membership info" do
  #       membership.privacy_settings = { "email"=>[0,0], "mobile"=>[0,0] }
  #       membership.can_read?(Circle::ADMIN_ROLE, "email").should be_false
  #       membership.can_read?(Circle::USER_ROLE, "email").should be_false     
  #       membership.can_read?(Circle::ADMIN_ROLE, "mobile").should be_false
  #       membership.can_read?(Circle::USER_ROLE, "mobile").should be_false
  #     end
  # 
  #   end
  
end
