require 'spec_helper'

describe Group do
  let(:user) { Factory(:user) }
  let(:group) { Group.create(:user=>user)  }
  
  it "is valid with valid attributes" do
    group.should be_valid
  end
      
end
