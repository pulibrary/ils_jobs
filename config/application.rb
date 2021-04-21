# frozen_string_literal: true
require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'zip'

module IlsApps
  class Application < Rails::Application
    def config_for(*args)
      OpenStruct.new(super(*args))
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.staff_directory = config_for(:staff_directory)

    config.cas = config_for(:cas)
    config.x.after_sign_out_url = config.cas.after_sign_out_url
  end
end

Zip.continue_on_exists_proc = true
