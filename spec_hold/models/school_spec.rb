require 'spec_helper'

describe School do
  let(:user) { Factory(:user) }
  let(:school) { Factory(:school)  }
  
  it "is valid with valid attributes" do
    school.should be_valid
  end
    
  it "is not valid without a category" do
    school.name=nil;
    school.should_not be_valid
    school.name="";
    school.should_not be_valid
  end

  it "has category label: public, private and charter" do
    school.enums(:category).should include(:public, :private,:charter)
  end

  it "raises an error for category other than public, private and charter" do
    expect { school.category = "religious" }.to raise_error(EnumeratedAttribute::InvalidEnumeration)
  end

  it "is not valid without a grade_range" do
    school.grade_range =  nil;
    school.should_not be_valid
    school.grade_range = "";
    school.should_not be_valid
  end

  it "is valid without a principal" do
    school.principal =  nil;
    school.should be_valid
    school.principal = "";
    school.should be_valid
  end

end
