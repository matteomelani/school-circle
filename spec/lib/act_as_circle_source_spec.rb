require 'spec_helper'

require 'active_record'
# db = ActiveRecord::Base.connection.instance_variable_get(:@connection)
ActiveRecord::Migration.verbose = false



describe "Acts As Circle Source" do
  
  before(:all) do
    ActiveRecord::Schema.define do
      create_table :fake_circle_sources, :force => true do |t|
        t.string :name
        t.integer :user_id
        t.timestamps
      end
    end
    class FakeCircleSource < ActiveRecord::Base
      
      belongs_to :user                       
      validates :user, :presence => true
      
      include ActsAsCircleSource
      acts_as_circle_source
       
      def owner_membership_roles
        ["pingu", "spongbob"]
      end
         
    end
  end

  after(:all) do
    ActiveRecord::Schema.define do
      drop_table :fake_circle_sources, :force => true
    end
  end
    
  let (:circle_source) { FakeCircleSource.new(:user=>Factory(:user)) } 
  
  it "is not valid without an user" do
    circle_source.user = nil
    circle_source.should_not be_valid
  end
  
  it "is not valid without a name" do
    circle_source.name = ""
    circle_source.should_not be_valid
    circle_source.name = nil
    circle_source.should_not be_valid  
  end
  
  it "is not valid with a name longer than 200 chars" do
    circle_source.name = 'a'*201
    circle_source.should_not be_valid
  end
    
  it "is valid if the name contains only letters, digits and the chars: '-', '_', ' '(white space)" do
    bad_names = ["The*Melanis", "The Melani!"]
    bad_names.each do |bad_name|
      circle_source.name = bad_name
      circle_source.should_not be_valid, " #{bad_name} should make circle source invalid instead family is valid!"
    end
  end

  context "when the name is blank" do
    it "has a default name that 'first_name last_name's <ClassName>'" do
      u=Factory(:user)
      u.profile.first_name="Rick"
      u.profile.last_name ="Schott"
      u.save!
      f = FakeCircleSource.new(:user=>u)
      f.name.should == "#{u.profile_full_name}'s #{circle_source.class.to_s}"
    end
  end
  
  it "creates a circle after it is saved" do
     circle_source.save
     circle_source.circle.should_not be_nil
     Circle.delete(circle_source.circle.id)
     circle_source.circle = nil
     circle_source.save
     circle_source.circle.should_not be_nil
   end
  
  it "allows concrete models to choose the owner membership roles" do
     circle_source.save
     circle_source.circle.memberships.first.roles.should == circle_source.owner_membership_roles
  end
end