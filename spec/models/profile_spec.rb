  require 'spec_helper'


describe Profile do

  let(:user) { Factory(:user) }
  let(:profile) { user.profile }

  describe "attributes validation" do

    it "is valid with valid attributes" do
      profile.should be_valid
    end

    it "should reject first name longer than 30 chars" do
      profile.first_name="a"*31
      profile.should_not be_valid
    end

    names=%w[matteo12 matteo* matteo_m matteo' matteo@gmail.com]
    names << "matteo melani"

    it "should reject first name that contains non letters" do
      names.each do |n|
        profile.first_name=n
        profile.should_not be_valid
      end
    end

    it "capitalizes first and last name" do
      profile.first_name="matteo"
      profile.first_name.should == "Matteo"
      profile.last_name="melani"
      profile.last_name.should == "Melani"
      
      profile.first_name = nil
      profile.first_name.should be_nil
      profile.last_name = nil
      profile.last_name.should be_nil
    end

    it "should reject last name longer than 30 chars" do
      profile.last_name="a"*31
      profile.should_not be_valid
    end

    it "should reject last name that contains non letters" do
      names.each do |n|
        profile.last_name=n
        profile.should_not be_valid
      end
    end
    
    it "should have by default when_confirmed set to the null" do
      profile.when_confirmed == nil
    end

    it "throws an exception when sex attribute is assigned a value other than male or female" do
      expect { profile.sex = "bla" }.to raise_error(EnumeratedAttribute::InvalidEnumeration)
    end

    it "is not valid with birthday occuring more than 110 years ago" do
      profile.birthday = (Date.today-110.years)-1.day
      profile.should_not be_valid
    end
      
    context "when time zone is left blank" do
      it "should have by default the time zone assigned to PST" do
        profile.time_zone.should == "Pacific Time (US & Canada)"
      end
    end

    context "when locale is left blank" do
      it "should have by default the locale set to en" do
        profile.locale == "en"
      end
    end

    context "when photo url is left blank" do
      it "should have by default photo url set to the default one" do
        profile.avatar_url == Profile::DEFAULT_PHOTO_URL
      end
    end
    
    context "when sex is left blank" do
      it "should have by default sex set to nil" do
        profile.sex.should == nil
      end
    end

    context "when main role is left blank" do
      it "should have by default main role set to nil" do
        profile.main_role.should == nil
      end
    end
    
  end

  describe "#language" do
    it "returns a the user language based on the user's choosen locale" do
      profile.language.should == "English"
    end
  end
  # describe "#first_name=" do
  #    it "capitilize and set the first_name" do
  #      profile
  #      profile.first_name.should == "English"
  #    end
  #    it "sets the first_name attribute to nil if value is nil" do
  #    end
  #  end

end




