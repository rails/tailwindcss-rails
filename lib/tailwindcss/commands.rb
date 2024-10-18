require "tailwindcss/ruby"

module Tailwindcss
  module Commands
    class << self
      def compile_command(debug: false, **kwargs)
        command = [
          Tailwindcss::Ruby.executable(**kwargs),
          "-i", Rails.root.join("app/assets/stylesheets/application.tailwind.css").to_s,
          "-o", Rails.root.join("app/assets/builds/tailwind.css").to_s,
          "-c", Rails.root.join("config/tailwind.config.js").to_s,
        ]

        command << "--minify" unless (debug || rails_css_compressor?)

        postcss_path = Rails.root.join("config/postcss.config.js")
        command += ["--postcss", postcss_path.to_s] if File.exist?(postcss_path)

        command
      end

      def watch_command(always: false, poll: false, **kwargs)
        compile_command(**kwargs).tap do |command|
          command << "-w"
          command << "always" if always
          command << "-p" if poll
        end
      end

      def rails_css_compressor?
        defined?(Rails) && Rails&.application&.config&.assets&.css_compressor.present?
      end
    end
  end
end
