require 'spec_helper'

describe PhoneNumber do

  let(:phone_number) { Factory(:phone_number, :owner=>Factory(:user)) }

  it "is valid with valid attributes" do
    phone_number.should be_valid
  end
  
  it "is valid with the following format: (555) 555-5555" do
    phone_numbers = [ "(555) 555-5555", "(555)555-5555", "5555555555"  ]
    phone_numbers.each do |pn| 
      phone_number.number = pn
      phone_number.should be_valid
    end  
  end
  
  it "is not valid without area code" do
    phone_number.number = "555-5555"
    phone_number.should_not be_valid  
  end
  
  it "is not valid with extension that is more than 5 digit"  do
     phone_number.extension = "555555"
     phone_number.should_not be_valid  
  end
  
  it "is not valid with extension that contains anything other than digits"  do
     extensions = %w[ 12$% 1234a w abcde ]
     extensions.each do |e|
       phone_number.extension = e
       phone_number.should_not be_valid
     end  
  end
  
  context "when it has a name" do
    it "to_s returns the full phone_number with the name and semicolon" do
      phone_number.name = "main"
      phone_number.to_s.should == "main: #{phone_number.number}"
    end
  end

  context "when it does not have a name" do
    it "to_s returns the full phone_number without the name and semicolon" do
      phone_number.name = ""
      phone_number.to_s.should == "#{phone_number.number}"
      phone_number.name = " "
      phone_number.to_s.should == "#{phone_number.number}"
    end
  end

  
end