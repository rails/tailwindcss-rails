module Tailwindcss
  class ServerProcess
    attr_reader :server, :pid

    def self.start
      new.start
    end

    def initialize
      @server = Server.new(self)
    end

    def start
      @pid = existing_process || start_process
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

    def existing_process
      if (pid = Pidfile.pid)
        begin
          Process.kill 0, pid
          pid
        rescue Errno::ESRCH
          # Process does not exist
        rescue Errno::EPERM
          # Ignore process owned by another user
        end
      end
    end

    def start_process
      pid = fork do
        Pidfile.write
        monitor_server
        exit_hook
        # Using IO.popen(command, 'r+') will avoid watch_command read from $stdin.
        # If we use system(*command) instead, IRB and Debug can't read from $stdin
        # correctly bacause some keystrokes will be taken by watch_command.
        IO.popen(Commands.watch_command, 'r+') do |io|
          IO.copy_stream(io, $stdout)
        end
      ensure
        Pidfile.delete
      end
      Process.detach pid
      pid
    end

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

    module Pidfile
      def self.path
        Rails.root.join("tmp", "pids", "tailwindcss.txt")
      end

      def self.read
        File.read(path, mode: "rb:UTF-8")
      rescue Errno::ENOENT
        # File does not exist
      end

      def self.write
        File.write(path, Process.pid, mode: "wb:UTF-8")
      end

      def self.delete
        File.exist?(path) && File.delete(path)
      end

      def self.pid
        Integer(read)
      rescue ArgumentError, TypeError
        # Invalid content
        delete
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
