Ziher::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.smtp_settings = {
    :enable_starttls_auto => false
  }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  # This option may cause significant delays in view rendering with a large
  # number of complex assets. 
  config.assets.debug = false

  config.assets.compile = true

  config.i18n.available_locales = :pl

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # log potential performance problems to bullet.log
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
  end

  config.eager_load = false
end
