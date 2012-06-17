ElectionMap::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true


config.perform_caching = true
	config.cache_store = :memory_store
=begin
	# Global enable/disable all memcached usage
	config.perform_caching = true
	# Disable/enable fragment and page caching in ActionController
	config.action_controller.perform_caching = true
	# The underlying cache store to use.
	config.cache_store = :dalli_store, '127.0.0.1:11211', { :namespace => "election-map-#{Rails.env}-cache", :expires_in => 1.day, :compress => true }
	# The session store is completely different from the normal data cache
	config.session_store = :dalli_store, '127.0.0.1:11211', { :namespace => "election-map-#{Rails.env}-session", :expires_in => 30.minutes, :compress => true }
	# this is a hack for development so can cache model objects in development
	require 'development/memcache_hack'
=end

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = false
  
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }  
	
	# small smtp server for dev, http://mailcatcher.me/
	config.action_mailer.smtp_settings = { :address => "127.0.0.1", :port => 1025 }

end
