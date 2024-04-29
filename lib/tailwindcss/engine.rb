require "rails"

module Tailwindcss
  class Engine < ::Rails::Engine
    config.tailwindcss = ActiveSupport::OrderedOptions.new
    config.tailwindcss.server_process = Rails.env.development?

    initializer "tailwindcss.assets" do
      Rails.application.config.assets.precompile += %w( inter-font.css )
    end

    initializer "tailwindcss.disable_generator_stylesheets" do
      Rails.application.config.generators.stylesheets = false
    end

    config.app_generators do |g|
      g.template_engine :tailwindcss
    end

    server do
      ServerProcess.start if config.tailwindcss.server_process
    end
  end
end
