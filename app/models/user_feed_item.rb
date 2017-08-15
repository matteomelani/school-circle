class UserFeedItem
  
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :title, :content, :author, :subtitle, :kind, :created_at, :circle, :real_post, :url
  
  def initialize(attributes = {})
    attributes.each do |name, value|
     send("#{name}=", value)
    end
  end
  
  def persisted?
    false
  end
  
end