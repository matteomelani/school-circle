class FamilyMember
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :name, :email, :school, :school_class, :birthday, :avatar, :role
  
  def initialize(attributes = {})
    attributes.each do |name, value|
     send("#{name}=", value)
    end
  end
  
  def persisted?
    false
  end
  
end
