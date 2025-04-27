require "tailwindcss/ruby"

module Tailwindcss
  module Commands
    class << self
      def rails_root
        defined?(Rails) ? Rails.root : Pathname.new(Dir.pwd)
      end

      def compile_command(input = rails_root.join("app/assets/tailwind/application.css").to_s, debug: false, **kwargs)
        debug = ENV["TAILWINDCSS_DEBUG"].present? if ENV.key?("TAILWINDCSS_DEBUG")

        command = [
          Tailwindcss::Ruby.executable(**kwargs),
          "-i", input,
          "-o", rails_root.join("app/assets/builds/tailwind.css").to_s,
        ]

        command << "--minify" unless (debug || rails_css_compressor?)

        postcss_path = rails_root.join("postcss.config.js")
        command += ["--postcss", postcss_path.to_s] if File.exist?(postcss_path)

        command
      end

      def watch_command(input = rails_root.join("app/assets/tailwind/application.css").to_s, always: false, poll: false, **kwargs)
        compile_command(input, **kwargs).tap do |command|
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

      def engines_roots
        return [] unless defined?(Rails)
        return [] unless Rails.application&.config&.tailwindcss_rails&.engines

        Rails::Engine.descendants.select do |engine|
          begin
            engine.engine_name.in?(Rails.application.config.tailwindcss_rails.engines)
          end
        end.map do |engine|
          [
            Rails.root.join("app/assets/tailwind/#{engine.engine_name}/application.css"),
            engine.root.join("app/assets/tailwind/#{engine.engine_name}/application.css")
          ].select(&:exist?).compact.first.to_s
        end.compact
      end

      def with_dynamic_input
        engine_roots = Tailwindcss::Commands.engines_roots
        if engine_roots.any?
          Tempfile.create('tailwind.css') do |file|
            file.write(engine_roots.map { |root| "@import \"#{root}\";" }.join("\n"))
            file.write("\n@import \"#{Rails.root.join('app/assets/tailwind/application.css')}\";\n")
            file.rewind
            yield file.path if block_given?
          end
        else
          yield rails_root.join("app/assets/tailwind/application.css").to_s if block_given?
        end
      end
    end
  end
end
