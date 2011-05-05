require 'thread'
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here

  config.frameworks -= [ :active_resource ]

  # config.gem 'ar_fixtures'
  # config.gem 'css_graphs'
  # config.gem 'haml'
  # config.gem 'hpricot', :source => 'http://code.whytheluckystiff.net'
  # config.gem 'has_many_polymorphs'
  # config.gem 'sparklines'
  # config.gem 'htmlentities'
  # # config.gem 'morph'
  # config.gem 'rugalytics'
  # config.gem 'twitter', :version => '~> 0.2.7'
  # config.gem 'ar-extensions'
  # config.gem 'will_paginate'
  # config.gem 'color'

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

  config.time_zone = 'UTC'

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # See Rails::Configuration for more options

  config.action_mailer.smtp_settings = {
    :address => "mail.theyworkforyou.co.nz",
    :port => 25,
    :domain => "theyworkforyou.co.nz",
    :user_name => "MyUsername",
    :password => "MyPassword",
    :authentication => :login
  }

  if RAILS_ENV == 'production'
    config.load_paths += [ '/home/x/opt/my_ruby_modules' ]
  end
end

require 'htmlentities'
require 'has_many_polymorphs'
require 'acts_as_slugged'
require 'acts_as_wikipedia'
require 'string_extensions_for_maori'
require 'date_extension'
require 'in_groups_by'
require 'route_helper'
require 'sitemap'
require 'expire_cache'
require 'color'
require 'will_paginate'

module Twfynz
  def self.twitter_update message
    httpauth = Twitter::HTTPAuth.new(twitter_user, twitter_password)
    twitter = Twitter::Base.new(httpauth)
    twitter.update message
  end
end

module ActiveSupport
  module Cache
    class FileStore < Store

      def write_with_chmod(name, value, options = nil)
        result = write_without_chmod(name, value, options)
        system "chmod a+w #{real_file_path(name)}" if result
        result
      end

      alias_method_chain :write, :chmod
    end
  end
end

