# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.11' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  
  # config.gem "rake",           :version => ">= 0.8.3"
  # config.gem "rack",           :version => ">= 0.9.1"
  config.gem "nokogiri"
  config.gem "libxml-ruby", :lib => 'xml'
  config.gem "erdgeist-chaos_calendar", :lib => "chaos_calendar", :source => "http://gems.github.com"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Allowed Tags
  # strong em b i p code pre tt samp kbd var sub sup dfn cite big small 
  # address hr br div span h1 h2 h3 h4 h5 h6 ul ol li dt dd abbr 
  # acronym a img blockquote del ins
  
  # Allowed Attributes:
  # href src width height alt cite datetime title class name xml:lang abbr))
  
  # Add tags to whitelist with:
  # config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td'
  
  # Add attributes to whitelist with:
  # config.action_view.sanitized_allowed_attributes = 'id', 'class', 'style'

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Berlin'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = :de
end

require 'awesome_patch'

ExceptionNotifier.exception_recipients = %w(hukl@berlin.ccc.de)
ExceptionNotifier.sender_address = %("CCCMS Error" <error@ccc.de>)
