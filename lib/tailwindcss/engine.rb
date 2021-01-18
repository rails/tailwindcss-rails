require "tailwindcss/compressor"

module Tailwindcss
  class Engine < ::Rails::Engine
    initializer "tailwindcss.compressor" do
      Sprockets.register_compressor "text/css", :purger, Tailwindcss::Compressor
    end

    initializer "tailwindcss.assets" do
      Rails.application.config.assets.precompile += %w( tailwind.css inter-font.css )
    end
  end
end
