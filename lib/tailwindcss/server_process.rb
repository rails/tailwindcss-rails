module Tailwindcss
  class ServerProcess
    attr_reader :server, :pid

    def self.start
      new.start
    end

    def start
      @server = Server.new(self)
      @pid = fork do
        monitor_server
        exit_hook
        # Using IO.popen(command, 'r+') will avoid watch_command read from $stdin.
        # If we use system(*command) instead, IRB and Debug can't read from $stdin
        # correctly bacause some keystrokes will be taken by watch_command.
        IO.popen(Commands.watch_command, 'r+') do |io|
          IO.copy_stream(io, $stdout)
        end
      end
      Process.detach pid

      server.monitor_process
      server.exit_hook
    end

    def stop
      return if dead?

      Process.kill(:INT, pid)
      Process.wait(pid)
    rescue Errno::ECHILD, Errno::ESRCH
    end

    def dead?
      Process.wait(pid, Process::WNOHANG)
      false
    rescue Errno::ECHILD, Errno::ESRCH
      true
    end

    private

    def monitor_server
      Thread.new do
        loop do
          if server.dead?
            puts "Tailwind detected server has gone away"
            exit
          end
          sleep 2
        end
      end
    end

    def exit_hook
      at_exit do
        puts "Stopping tailwind..."
        server.stop
      end
    end

    class Server
      attr_reader :process, :pid

      def initialize(process)
        @process = process
        @pid = Process.pid
      end

      def monitor_process
        Thread.new do
          loop do
            if process.dead?
              puts "Detected tailwind has gone away, stopping server..."
              exit
            end
            sleep 2
          end
        end
      end

      def exit_hook
        at_exit do
          process.stop
        end
      end

      def dead?
        Process.ppid != pid
      end

      def stop
        Process.kill(:INT, pid)
      rescue Errno::ECHILD, Errno::ESRCH
      end
    end
  end
end
