# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.1' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here

  # Skip frameworks you're not going to use (only works if using vendor/rails)
  config.frameworks -= [ :active_resource ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  config.action_controller.session = {
    :session_key => '_twfy3_session',
    :secret      => 'a387d6564d1804e8af44d5ec5256a751'
  }

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc

  # See Rails::Configuration for more options

  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory is automatically loaded

  config.action_mailer.smtp_settings = {
    :address => "mail.theyworkforyou.co.nz",
    :port => 25,
    :domain => "theyworkforyou.co.nz",
    :user_name => "MyUsername",
    :password => "MyPassword",
    :authentication => :login
  }

  config.gem 'ar_fixtures'
  config.gem 'css_graphs'
  # config.gem 'haml'
  config.gem 'hpricot', :source => 'http://code.whytheluckystiff.net'
  config.gem 'has_many_polymorphs'
  config.gem 'SyslogLogger'
  config.gem 'sparklines'
end

#require 'htmlentities'
require 'acts_as_slugged'
require 'string_extensions_for_maori'
require 'date_extension'
require 'in_groups_by'
#require 'sitemap'
