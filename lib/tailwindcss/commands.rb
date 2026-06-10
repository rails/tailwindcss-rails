require "tailwindcss/ruby"

module Tailwindcss
  module Commands
    INPUT_FILE = "app/assets/tailwind/application.css"
    OUTPUT_FILE = "app/assets/builds/tailwind.css"

    class << self
      def compile_command(debug: false, **kwargs)
        debug = ENV["TAILWINDCSS_DEBUG"].present? if ENV.key?("TAILWINDCSS_DEBUG")
        rails_root = defined?(Rails) ? Rails.root : Pathname.new(Dir.pwd)

        command = [
          Tailwindcss::Ruby.executable(**kwargs),
          "-i", rails_root.join(input_file).to_s,
          "-o", rails_root.join(output_file).to_s,
        ]

        command << "--minify" unless (debug || rails_css_compressor?)

        postcss_path = rails_root.join("postcss.config.js")
        command += ["--postcss", postcss_path.to_s] if File.exist?(postcss_path)

        command
      end

      def watch_command(always: false, **kwargs)
        compile_command(**kwargs).tap do |command|
          command << "-w"
          command << "always" if always
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

      def input_file
        ENV.fetch("TAILWINDCSS_INPUT_FILE", INPUT_FILE)
      end

      def output_file
        ENV.fetch("TAILWINDCSS_OUTPUT_FILE", OUTPUT_FILE)
      end
    end
  end
end
