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
        # To avoid stealing keystrokes from the debug gem's IRB console in the main process (which
        # needs to be able to read from $stdin), we use `IO.open(..., 'r+')`.
        IO.popen(Tailwindcss::Commands.watch_command, 'r+') do |io|
          IO.copy_stream(io, $stdout)
        end
      end
      at_exit do
        Process.kill(:INT, tailwind_pid)
      end
    end
  end
end
