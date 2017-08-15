# Load the rails application
require File.expand_path('../application', __FILE__)

Theschoolcircle::Application.configure do
  
  # This is the domain to use when composing email addresses or when ever the official The School Circle
  # email is needed
  config.official_domain = "theschoolcircle.com"
  config.db_version = "9.0.3"
  
end

# Initialize the rails application
Theschoolcircle::Application.initialize!


