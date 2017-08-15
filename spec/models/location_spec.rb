require 'spec_helper'
   
describe Location do
 
 it "is valid with valid attributes" do
   Location.stub(:geocode).and_return(nil)
   location = Location.create(:input_string=>"Menlo Park")
 end
 
 it "accepts an input string and perform geocoding before saving (geocoder mocked)" do
   loc  = mock('loc')
   loc.stub(:success).and_return(true)
   loc.stub(:full_address).and_return("Menlo Park, CA, USA")
   Location.stub(:geocode).and_return(loc)
   location = Location.create(:input_string=>"Menlo Park")
   location.input_string.should == "Menlo Park, CA, USA"
 end
  
  
end
