require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)
require "tailwindcss-rails"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    config.paths["app/views"].unshift("#{Rails.root}/app/custom_views")
  end
end
