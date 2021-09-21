require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require "tailwindcss-rails"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    config.paths["app/views"].unshift("#{Rails.root}/app/custom_views")

    # Configuration to set custom_views as another files_with_class_names for Tailwindcss
    # config.tailwind.files_with_class_names += Rails.root.glob("app/custom_views/**/*.*")

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
