require "tailwindcss/compressor"

module Tailwindcss
  class Engine < ::Rails::Engine
    initializer "tailwindcss.compressor" do
      Sprockets.register_compressor "text/css", :purger, Tailwindcss::Compressor
    end

    initializer "tailwindcss.assets" do
      Rails.application.config.assets.precompile += %w( tailwind.css inter-font.css )
    end

    initializer "tailwindcss.disable_generator_stylesheets" do
      Rails.application.config.generators.stylesheets = false
    end

    initializer "tailwindcss.disable_assets_cache" do
      Rails.application.config.assets.configure do |env|
        env.cache = ActiveSupport::Cache.lookup_store(:null_store)
      end if Rails.env.production?
    end
  end
end
