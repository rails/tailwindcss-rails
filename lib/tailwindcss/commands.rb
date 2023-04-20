require_relative "upstream"

module Tailwindcss
  module Commands
    DEFAULT_DIR = File.expand_path(File.join(__dir__, "..", "..", "exe"))

    # raised when the host platform is not supported by upstream tailwindcss's binary releases
    class UnsupportedPlatformException < StandardError
    end

    # raised when the tailwindcss executable could not be found where we expected it to be
    class ExecutableNotFoundException < StandardError
    end

    # raised when TAILWINDCSS_INSTALL_DIR does not exist
    class DirectoryNotFoundException < StandardError
    end

    class << self
      def platform
        [:cpu, :os].map { |m| Gem::Platform.local.send(m) }.join("-")
      end

      def executable(exe_path: DEFAULT_DIR)
        tailwindcss_install_dir = ENV["TAILWINDCSS_INSTALL_DIR"]
        if tailwindcss_install_dir
          if File.directory?(tailwindcss_install_dir)
            warn "NOTE: using TAILWINDCSS_INSTALL_DIR to find tailwindcss executable: #{tailwindcss_install_dir}"
            exe_path = tailwindcss_install_dir
            exe_file = File.expand_path(File.join(tailwindcss_install_dir, "tailwindcss"))
          else
            raise DirectoryNotFoundException, <<~MESSAGE
              TAILWINDCSS_INSTALL_DIR is set to #{tailwindcss_install_dir}, but that directory does not exist.
            MESSAGE
          end
        else
          if Tailwindcss::Upstream::NATIVE_PLATFORMS.keys.none? { |p| Gem::Platform.match(Gem::Platform.new(p)) }
            raise UnsupportedPlatformException, <<~MESSAGE
              tailwindcss-rails does not support the #{platform} platform
              Please install tailwindcss following instructions at https://tailwindcss.com/docs/installation
            MESSAGE
          end

          exe_file = Dir.glob(File.expand_path(File.join(exe_path, "*", "tailwindcss"))).find do |f|
            Gem::Platform.match(Gem::Platform.new(File.basename(File.dirname(f))))
          end
        end

        if exe_file.nil? || !File.exist?(exe_file)
          raise ExecutableNotFoundException, <<~MESSAGE
            Cannot find the tailwindcss executable for #{platform} in #{exe_path}

            If you're using bundler, please make sure you're on the latest bundler version:

                gem install bundler
                bundle update --bundler

            Then make sure your lock file includes this platform by running:

                bundle lock --add-platform #{platform}
                bundle install

            See `bundle lock --help` output for details.

            If you're still seeing this message after taking those steps, try running
            `bundle config` and ensure `force_ruby_platform` isn't set to `true`. See
            https://github.com/rails/tailwindcss-rails#check-bundle_force_ruby_platform
            for more details.
          MESSAGE
        end

        exe_file
      end

      def compile_command(debug: false, **kwargs)
        [
          executable(**kwargs),
          "-i", Rails.root.join("app/assets/stylesheets/application.tailwind.css").to_s,
          "-o", Rails.root.join("app/assets/builds/tailwind.css").to_s,
          "-c", Rails.root.join("config/tailwind.config.js").to_s,
        ].tap do |command|
          command << "--minify" unless (debug || rails_css_compressor?)
        end
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
