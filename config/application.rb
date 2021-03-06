require File.expand_path('../boot', __FILE__)

require 'rails/all'

require 'elasticsearch/rails/instrumentation'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Ontohub
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.eager_load_paths += %W(#{config.root}/lib)

    # HACK https://gist.github.com/1184816
    if defined? Compass
      config.sass.load_paths << Compass::Frameworks['compass'].stylesheets_directory
    end

    # Mailer Layout for Devise https://github.com/plataformatec/devise/issues/1671
    config.to_prepare { Devise::Mailer.layout "mailer" }

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.i18n.enforce_available_locales = true

    # Including Jstree Themes Styles in Precompiling
    config.assets.precompile += %w(jstree-themes/**/*)

    #Including the external mappings Yaml-file
    config.external_url_mapping = APP_CONFIG = YAML.load(File.read(Rails.root + "config/external_link_mapping.yml"))

    config.before_initialize do
      local_environment_config = config.root.join('config', 'environments',
                                                  "#{Rails.env}.local.rb")
      require local_environment_config if File.exists?(local_environment_config)

      RailsConfig.overwrite_arrays = true

      Settings.add_source!(Rails.root.join('config', 'hets.yml').to_s)
      Settings.reload!

      # Enable serving of images, stylesheets, and JavaScripts from an asset server
      config.action_controller.asset_host = Settings.asset_host

      # ActionMailer settings
      require config.root.join('config', 'initializers', 'hostname.rb')
      Settings.action_mailer[:default_url_options] ||= {}
      Settings.action_mailer[:default_url_options] =
        Settings.action_mailer[:default_url_options].to_hash
      Settings.action_mailer[:default_url_options][:host] ||= config.fqdn
      Settings.action_mailer[:default_url_options][:port] ||= config.port
      Settings.action_mailer.each do |key, value|
        config.action_mailer.send("#{key}=", value)
      end
    end

    config.after_initialize do
      SettingsValidator.new.validate!
      SettingsInterpreter.new.call
      Sidekiq::Logging.logger.level =
        Kernel.const_get("Logger::#{Settings.asynchronous_execution.log_level}")
    end
  end
end
