require 'spec_helper'

describe Classroom do
  let(:user) { Factory(:user) }
  let(:classroom) { Classroom.create(:user=>user)  }
  
  it "is valid with valid attributes" do
    classroom.should be_valid
  end    
    
end
