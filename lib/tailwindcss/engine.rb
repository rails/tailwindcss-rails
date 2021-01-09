require "tailwindcss/purger"

module Tailwindcss
  class Engine < ::Rails::Engine
    initializer "tailwindcss.assets" do
      Rails.application.config.assets.precompile += %w( tailwindcss/tailwind )
    end
  end
end
