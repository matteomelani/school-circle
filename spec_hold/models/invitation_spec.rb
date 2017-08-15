require 'spec_helper'


describe Invitation do

  let(:invitation) { Factory(:invitation) }
  
  it "is valid with valid attributes" do
     invitation.should be_valid
  end
  
  it "has the expiration set to 30 days from the creation date by default" do
    invitation.expires_on.should < Invitation::STANDARD_VALIDITY.days.from_now
  end 
  
  it "is not valid if the email is not valid" do
    invitation.email = "gino&pino.com"
    invitation.should_not be_valid
  end 
  
  it "is not valid without a circle" do
    invitation.circle_id = nil
    invitation.should_not be_valid        
  end
  
  it "should always have a unique token" do
    s = Set.new
    a =[]
    for i in 1..10 do
       inv = Factory(:invitation)
       a << inv
       s << inv.token
    end
    s.count.should == 10
  end
  
  describe "#memberships" do
    it "returns the memeberships as Membership object defined in the registration_info" do
      invitation.registration_info = {
        :memberships=>[
                {:circle_id=>1, :roles=>[Circle::ADMIN_ROLE]},
                {:circle_id=>2, :roles=>[Circle::ADMIN_ROLE, Circle::USER_ROLE]},
                {:circle_id=>3, :roles=>[Circle::USER_ROLE]},
                ]
      }
      invitation.memberships.count.should == invitation.registration_info[:memberships].count
      invitation.registration_info[:memberships].each_with_index do |membership_attributes, index|
        invitation.memberships[index].circle_id.should  == membership_attributes[:circle_id]
        invitation.memberships[index].roles.count.should == membership_attributes[:roles].count
        invitation.memberships[index].roles.each do |r|
          membership_attributes[:roles].include?(r).should be_true 
        end
      end 
    end
  end
  
  describe "#accept" do
    it "creates a defult user membership to the specified circle for the invited user" do
      #create a user
      user1 = Factory(:user)
      user2 = Factory(:user)
      invitation =   Invitation.create!(:inviter=>user1, :circle=>user1.personal_circle, :email=>user2.email)
      invitation.accept
      user2.has_user_membership_for?(user1.personal_circle).should be_true
    end
    
    it "creates a membership as specified in registration_info" do
      #create a user
      user1 = Factory(:user)
      user2 = Factory(:user)
      invitation =  Invitation.create!(:inviter=>user1, :circle=>user1.personal_circle, :email=>user2.email)
      invitation.registration_info= {:memberships=>[{:circle_id=>user1.personal_circle.id, :roles=>[Circle::ADMIN_ROLE, Circle::USER_ROLE]}]}
      invitation.accept
      user2.has_user_membership_for?(user1.personal_circle).should be_true
      user2.has_admin_membership_for?(user1.personal_circle).should be_true
    end
  
    it "ensures the new membeship to the Family circle does not have a MY_FAMILY role in it" do
      #TODO: finish me
      pending
    end
    
  end
  
end
