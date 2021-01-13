require "tailwindcss/purger"

module Tailwindcss
  class Engine < ::Rails::Engine
    initializer "tailwindcss.compressor" do
      Sprockets.register_compressor "text/css", :purger, Tailwindcss::Compressor
    end

    initializer "tailwindcss.assets" do
      Rails.application.config.assets.precompile += %w( tailwind )
    end
  end
end
