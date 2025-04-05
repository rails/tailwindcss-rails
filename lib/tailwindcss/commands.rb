require "tailwindcss/ruby"

module Tailwindcss
  module Commands
    class << self
      def compile_command(debug: false, **kwargs)
        debug = ENV["TAILWINDCSS_DEBUG"].present? if ENV.key?("TAILWINDCSS_DEBUG")
        rails_root = defined?(Rails) ? Rails.root : Pathname.new(Dir.pwd)

        command = [
          Tailwindcss::Ruby.executable(**kwargs),
          "-i", rails_root.join("app/assets/tailwind/application.css").to_s,
          "-o", rails_root.join("app/assets/builds/tailwind.css").to_s,
        ]

        command << "--minify" unless (debug || rails_css_compressor?)

        postcss_path = rails_root.join("postcss.config.js")
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

      def command_env(verbose:)
        {}.tap do |env|
          env["DEBUG"] = "1" if verbose
        end
      end

      def rails_css_compressor?
        defined?(Rails) && Rails&.application&.config&.assets&.css_compressor.present?
      end
    end
  end
end
