require "tailwindcss/compressor"

module Tailwindcss
  class Engine < ::Rails::Engine
    config.tailwind                         = ActiveSupport::OrderedOptions.new
    config.tailwind.files_with_class_names  = []

    initializer "set files with class names" do
      config.tailwind.files_with_class_names += Rails.root.glob("app/views/**/*.*") + Rails.root.glob("app/helpers/**/*.rb") + Rails.root.glob("app/javascript/**/*.js")
    end

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

     config.app_generators do |g|
       g.template_engine :tailwindcss
     end
  end
end
