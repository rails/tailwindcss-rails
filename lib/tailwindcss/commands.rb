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

      def engines_tailwindcss_roots
        return [] unless defined?(Rails)

        Rails::Engine.subclasses.select do |engine|
          begin
            spec = Gem::Specification.find_by_name(engine.engine_name)
            spec.dependencies.any? { |d| d.name == 'tailwindcss-rails' }
          rescue Gem::MissingSpecError
            false
          end
        end.map do |engine|
          [
            Rails.root.join("app/assets/tailwind/#{engine.engine_name}/application.css"),
            engine.root.join("app/assets/tailwind/#{engine.engine_name}/application.css")
          ].select(&:exist?).compact.first.to_s
        end.compact
      end

      def enhance_command(command)
        engine_roots = Tailwindcss::Commands.engines_tailwindcss_roots
        if engine_roots.any?
          Tempfile.create('tailwind.css') do |file|
            file.write(engine_roots.map { |root| "@import \"#{root}\";" }.join("\n"))
            file.write("\n@import \"#{Rails.root.join('app/assets/tailwind/application.css')}\";\n")
            file.rewind
            transformed_command = command.dup
            transformed_command[2] = file.path
            yield transformed_command if block_given?
          end
        else
          yield command if block_given?
        end
      end
    end
  end
end
