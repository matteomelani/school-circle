Theschoolcircle::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true 
  
  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH
  
  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true
  
  # See everything in the log (default is :info)
  config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store
 
  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )
  #
  # blueprint *.css are are precompiled so that are available for download, the application
  # than chooses what to download in _stylesheet.html.haml.
  # We cannot include blueprint in vendor.css becuse the app chooses what it need based on 
  # browser and media.
  config.assets.precompile += %w( blueprint/screen.css blueprint/print.css blueprint/ie.css )
  
  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  #ActionMailer config
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :domain => 'theschoolcircle.com',
    :authentication => :plain,
    :user_name => '',
    :password => ''
  }

  # The app domain is determined by the domain we use to deploy it.
  config.app_domain = 'theschoolcircle.com'
  
  # This is the hostname mailer uses to create URL to put in emails  
  config.action_mailer.default_url_options = { :host=>config.app_domain }

  config.logger = Logger.new(STDOUT)
  config.log_level = Logger::DEBUG
  
  config.db_version = "8.3"
  
  config.paperclip_storage_options = {  
       :storage=>:s3, 
       :s3_credentials=>"#{Rails.root}/config/s3.yml", 
       :path=>"/public/content/:basename_:style.:extension"}
end
