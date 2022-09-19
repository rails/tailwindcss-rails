require_relative "upstream"

module Tailwindcss
  module Commands
    # raised when the host platform is not supported by upstream tailwindcss's binary releases
    class UnsupportedPlatformException < StandardError
    end

    # raised when the tailwindcss executable could not be found where we expected it to be
    class ExecutableNotFoundException < StandardError
    end

    class << self
      def platform
        [:cpu, :os].map { |m| Gem::Platform.local.send(m) }.join("-")
      end

      def executable(
        exe_path: File.expand_path(File.join(__dir__, "..", "..", "exe"))
      )
        if Tailwindcss::Upstream::NATIVE_PLATFORMS.keys.none? { |p| Gem::Platform.match(Gem::Platform.new(p)) }
          raise UnsupportedPlatformException, <<~MESSAGE
            tailwindcss-rails does not support the #{platform} platform
            Please install tailwindcss following instructions at https://tailwindcss.com/docs/installation
          MESSAGE
        end

        exe_path = Dir.glob(File.expand_path(File.join(exe_path, "*", "tailwindcss"))).find do |f|
          Gem::Platform.match(Gem::Platform.new(File.basename(File.dirname(f))))
        end

        if exe_path.nil?
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

        exe_path
      end

      def compile_command(debug: false, **kwargs)
        [
          executable(**kwargs),
          "-i", Rails.root.join("app/assets/stylesheets/application.tailwind.css").to_s,
          "-o", Rails.root.join("app/assets/builds/tailwind.css").to_s,
          "-c", Rails.root.join("config/tailwind.config.js").to_s,
        ].tap do |command|
          command << "--minify" unless debug
        end
      end

      def watch_command(poll: false, **kwargs)
        compile_command(**kwargs).tap do |command|
          command << "-w"
          command << "-p" if poll
        end
      end
    end
  end
end
