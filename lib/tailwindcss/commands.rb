require "shellwords"
require "tailwindcss/ruby"

module Tailwindcss
  module Commands
    # Signals we forward to the spawned tailwindcss process so it shuts down
    # with us instead of being orphaned.
    FORWARDED_SIGNALS = %w[INT TERM].freeze

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

      def watch_command(always: false, **kwargs)
        compile_command(**kwargs).tap do |command|
          command << "-w"
          command << "always" if always
        end
      end

      # Spawn the tailwindcss watcher and block until it exits, forwarding INT
      # (Ctrl-C) and TERM (foreman/systemd/Docker shutdown) to it so a stopping
      # supervisor doesn't leave an orphaned watcher behind.
      def watch(always: false, debug: false, verbose: false)
        pid = nil
        received_signal = nil
        previous_traps = {}

        command = watch_command(always: always, debug: debug)
        env = command_env(verbose: verbose)
        if verbose
          puts "Running: #{Shellwords.join(command)}"
        end

        forward_signal = ->(signal) do
          if pid
            Process.kill(signal, pid)
          end
        rescue Errno::ESRCH
          # tailwindcss already exited
        end

        # Trap immediately before spawning. If a signal lands before pid is
        # assigned, remember it and forward it once the child exists.
        FORWARDED_SIGNALS.each do |signal|
          previous_traps[signal] = trap(signal) do
            received_signal ||= signal
            forward_signal.call(signal)
          end
        end

        pid = Process.spawn(env, *command)
        # If a signal arrived during spawn (before pid was set), the handler
        # couldn't forward it yet, so forward it now.
        if received_signal
          forward_signal.call(received_signal)
        end
        Process.wait(pid)
        # Drop the pid so a late signal can't kill a process that reused it.
        pid = nil

        if verbose && received_signal
          puts "Received #{received_signal}, exiting tailwindcss:watch"
        end
      ensure
        previous_traps.each do |signal, previous_trap|
          trap(signal, previous_trap)
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
