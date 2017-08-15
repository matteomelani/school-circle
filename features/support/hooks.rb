# require 'cucumber/rails'
# require 'capybara'

Before("@smoke") do
  # include Capybara
  Capybara.run_server = false
  Capybara.current_driver = :selenium
  target_host = TARGET_HOST || ENV['TARGET_HOST'] 
  Capybara.app_host = target_host.nil? ? "http://localhost:3000" : "http://#{target_host}"
end