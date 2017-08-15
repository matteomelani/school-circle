require 'spec_helper'

describe User do

  let(:user) { Factory(:user) }

  it "is valid with valid attributes" do
    user.profile.should be_valid
    user.should be_valid
  end

  it "is not valid with a blank email" do
    user.email = ""
    user.should_not be_valid
    user.email = nil
    user.should_not be_valid
  end

  it "is not valid with a wrongly formatted email" do
    emails=%w[user@foo,com user_at_foo.org example.user@foo.]
    emails.each do |e|
      user.email = e
      user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    user2 = Factory.build(:user)
    user2.email = user.email
    user2.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    user2 = Factory.build(:user)
    user2.email=user.email.upcase
    user2.should_not be_valid
    user2.email=user.email.capitalize
    user2.should_not be_valid
  end

  it "is not valid with a blank password" do
    user.password = nil
    user.should_not be_valid
    user.password = ""
    user.should_not be_valid
  end

  it "should reject username identical up to case" do
    user2 = Factory.build(:user)
    user2.username = user.username.upcase
    user2.should_not be_valid
    user2.username = user.username.capitalize
    user2.should_not be_valid
  end
  
  context "there are 2 users with the same email username (matteo@gmail.com and matteo@yahoo.com)" do
    it "should crate a unique username by appending an integer" do
      user1 = Factory(:user)
      user2 = Factory(:user, :email=>"#{user1.username}@pinetta.com")
      user2.username.should == "#{user1.username}_1"
      user3 = Factory(:user, :email=>"#{user1.username}@pino.com")
      user3.username.should == "#{user1.username}_2"
    end
  end 
  
  it "should reject username that contains non-alphanumeric char" do
    usernames=%w[matteo* matteo' matteo@gmail.com]
    usernames << "matteo melani"
    usernames.each do |un|
      user.username = un
      user.should_not be_valid
    end
  end

  it "should accepts username that contains . and - chars" do
    usernames=%w[matteo.matteo matteo-melani]
    usernames.each do |un|
      user.username = un
      user.should be_valid

    end
  end

  it "should reject username longer than 24 chars" do
    user.username = "marco"*5
    user.should_not be_valid
  end

  context "when the username is left blank" do
    it "should set the username using the email username" do
      user.username.should == user.email.split("@")[0]
    end
  end

  it "should have a personal circle" do
    user.owned_circles.count.should == 1
    user.owned_circles[0].name.should == "#{user.profile_full_name}'s Personal Circle"
    user.owned_circles[0].source.should == user
  end

  describe "#postable_circles" do
    it "returns a list of circle the user can post to" do
      user.postable_circles.count.should == 1 # for sure it should be able to write on its own circle
      user.postable_circles.include?(user.owned_circles[0]).should be_true
    end
  end

  describe "#has_role?" do
    it "returns true if the user has a role 'R' towards an object 'O'" do
      user.has_role?(Circle::ADMIN_ROLE, user.personal_circle).should be_true
      user.has_role?(Circle::USER_ROLE, user.personal_circle).should be_true
      user.has_role?("pino", user.personal_circle).should be_false
    end
    it "thorws an exception if 2 arguments are not passed" do
      lambda { user.has_role?("", user.personal_circle) }.should raise_error
      lambda { user.has_role?(Circle::ADMIN_ROLE, nil) }.should raise_error
    end
    
  end
  
  describe "#my_family" do
    it "returns and empty array if the user does not have a primary family" do
      user.my_family.should be_nil 
    end
    it "returns the family the user primary family" do
      family=Factory(:family, :user=>user)
      user.my_family.id.should == family.id
    end
  end
  
  describe "#neighbours" do
    context "when the user belongs to only his personal circle" do
      it "returns and array of user with one element: the user itself" do
        user.neighbours.count.should == 1
        user.neighbours[0].should == user
      end
    end
    context "when the user belongs to 2 circles" do
      it "returns a array containing the union of the members of the 2 circles, the element are sorted by user full name" do
        c = Classroom.create(:user=>user)
        user2 = Factory(:user)
        user2.profile.first_name = "amir"
        user2.save
        c.circle.members << user2
        user3 = Factory(:user)
        user3.profile.first_name = "bamir"
        user3.save
        c.circle.members << user3
        
        user.neighbours.count.should == 3
        user.neighbours.include?(user2).should be_true 
        user.neighbours.include?(user3).should be_true
        
        r=[user,user2,user3].sort{|a,b| a.profile.full_name.downcase <=> b.profile.full_name.downcase }
        (user.neighbours<=>r).should == 0
      end
    end
    
  end
  
end

