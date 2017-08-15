require 'spec_helper'


describe Address do

  let(:address) do
    Address.any_instance.stub(:geolocate).and_return(nil)    
    a = Factory(:address, :owner=>Factory(:user))
  end
  before(:all) do

  end

  it "is valid with valid attributes" do
    Address.any_instance.stub(:geolocate).and_return(nil)    
    address.should be_valid
  end

  it "is not valid with a blank line1" do
    address.line1 = ""
    address.should_not be_valid
    address.line1 = nil
    address.should_not be_valid
  end

  it "is not valid with a blank city" do
    address.city = ""
    address.should_not be_valid
    address.city = nil
    address.should_not be_valid
  end

  it "is not valid with a blank state" do
    address.state = ""
    address.should_not be_valid
    address.state = nil
    address.should_not be_valid
  end

  it "is not valid with a blank zipcode" do
    address.zipcode = ""
    address.should_not be_valid
    address.zipcode = nil
    address.should_not be_valid
  end

  it "is valid with a zipcode that is an integer of 5 digits" do
    address.zipcode = 9.1
    address.should_not be_valid
    address.zipcode = 1
    address.should_not be_valid
    address.zipcode = 123456
    address.should_not be_valid
  end

  it "is valid with the state that is 2 letters" do
    ["A", "AAA"].each do |s|
      address.state = s
      address.should_not be_valid
    end
  end

  it "is not valid without an owner" do
    address.owner=nil
    address.should_not be_valid
  end

  it "is valid without a label (with a blank label)" do
    address.label=nil
    address.should  be_valid
    address.label=""
    address.should  be_valid
  end

  context "when it has a label" do
    it "to_s returns the full address with the label and semicolon" do
      address.label = "main"
      address.to_s.should == "main: #{address.line1} #{address.city}, #{address.state} #{address.zipcode} #{address.country}"
      address.line2 = "apt 34/f"
      address.to_s.should == "main: #{address.line1}, #{address.line2} #{address.city}, #{address.state} #{address.zipcode} #{address.country}"

    end
  end

  context "when it does not have a label" do
    it "to_s returns the full address without the label and semicolon" do
      address.label = ""
      address.to_s.should == "#{address.line1} #{address.city}, #{address.state} #{address.zipcode} #{address.country}"
      address.label = " "
      address.to_s.should == "#{address.line1} #{address.city}, #{address.state} #{address.zipcode} #{address.country}"
    end
  end

end
