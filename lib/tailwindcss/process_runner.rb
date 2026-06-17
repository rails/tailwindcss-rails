module Tailwindcss
  # Runs a child process and forwards stop signals (INT/TERM) to it, blocking
  # until it exits, so a process manager that signals this process directly
  # (e.g. foreman) doesn't leave the child orphaned. Shaped like
  # +Process.spawn+/+Kernel#system+: it takes an +env+ hash followed by the
  # command.
  module ProcessRunner
    # Signals we forward to the spawned process so it shuts down with us instead
    # of being orphaned.
    FORWARDED_SIGNALS = %w[INT TERM].freeze

    class << self
      # Spawn +command+ with +env+ and block until it exits, forwarding INT
      # (Ctrl-C) and TERM (e.g. foreman shutdown) to it so a process manager
      # that signals us directly doesn't leave an orphaned child behind.
      # Restores the previous signal handlers before returning so the
      # process-global traps aren't left changed. Returns the name of the signal
      # that was received (e.g. "TERM"), or nil if the child exited on its own.
      def spawn_and_wait(env, *command)
        pid = nil
        received_signal = nil
        previous_traps = {}

        forward_signal = ->(signal) do
          if pid
            Process.kill(signal, pid)
          end
        rescue Errno::ESRCH
          # the child already exited
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

        received_signal
      ensure
        previous_traps.each do |signal, previous_trap|
          trap(signal, previous_trap)
        end
      end
    end
  end
end
