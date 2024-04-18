require "rails"

module Tailwindcss
  class Engine < ::Rails::Engine
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
      tailwind_pid = fork do
        exec(*Tailwindcss::Commands.watch_command(always: true))
      end
      at_exit do
        Process.kill(:INT, tailwind_pid)
      end
    end
  end
end
