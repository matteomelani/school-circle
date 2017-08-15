Theschoolcircle::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  # config.action_mailer.raise_delivery_errors = true

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
      :address=>'smtp.sendgrid.net',
      :port => 587,
      :domain => 'theschoolcircle.com',
      :authentication => :plain,
      :user_name => '',
      :password => ''
    }
    
  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Do not compress assets
  config.assets.compress = false
  config.reload_classes_only_on_change = false

  # Expands the lines which load the assets
  config.assets.debug = true
  
  # This is does not work see the workaround in initializers/asset_quiet.rb
  # config.assets.logger = nil
  
  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # The app domain is determined by the domain we use to deploy it.
  config.app_domain = 'localhost:3000'

  # This is the hostname mailer uses to create URL to put in emails  
  config.action_mailer.default_url_options = { :host=>config.app_domain }
  
  config.paperclip_storage_options = {
    :path=>"public/assets/content/:basename_:style.:extension",
    :url=>"content/:basename_:style.:extension"
  }
  
  
end
