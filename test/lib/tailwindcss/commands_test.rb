require "test_helper"
require "minitest/mock"

class Tailwindcss::CommandsTest < ActiveSupport::TestCase
  attr_accessor :executable

  def setup
    super
    @executable = Tailwindcss::Ruby.executable
  end

  test ".compile_command" do
    Rails.stub(:root, File) do # Rails.root won't work in this test suite
      actual = Tailwindcss::Commands.compile_command
      assert_kind_of(Array, actual)
      assert_equal(executable, actual.first)
      assert_includes(actual, "-i")
      assert_includes(actual, "-o")
    end
  end

  test ".compile_command debug flag" do
    Rails.stub(:root, File) do # Rails.root won't work in this test suite
      actual = Tailwindcss::Commands.compile_command
      assert_kind_of(Array, actual)
      assert_equal(executable, actual.first)
      assert_includes(actual, "--minify")

      actual = Tailwindcss::Commands.compile_command(debug: true)
      assert_kind_of(Array, actual)
      assert_equal(executable, actual.first)
      refute_includes(actual, "--minify")
    end
  end

  test ".compile_command debug environment variable" do
    begin
      Rails.stub(:root, File) do # Rails.root won't work in this test suite
        ENV["TAILWINDCSS_DEBUG"] = ""
        actual = Tailwindcss::Commands.compile_command
        assert_kind_of(Array, actual)
        assert_includes(actual, "--minify")

        actual = Tailwindcss::Commands.compile_command(debug: true)
        assert_kind_of(Array, actual)
        assert_includes(actual, "--minify")

        ENV["TAILWINDCSS_DEBUG"] = "any non-blank value"
        actual = Tailwindcss::Commands.compile_command
        assert_kind_of(Array, actual)
        refute_includes(actual, "--minify")

        actual = Tailwindcss::Commands.compile_command(debug: true)
        assert_kind_of(Array, actual)
        refute_includes(actual, "--minify")
      end
    ensure
      ENV.delete('TAILWINDCSS_DEBUG')
    end
  end

  test ".compile_command when Rails compression is on" do
    Rails.stub(:root, File) do # Rails.root won't work in this test suite
      Tailwindcss::Commands.stub(:rails_css_compressor?, true) do
        actual = Tailwindcss::Commands.compile_command
        assert_kind_of(Array, actual)
        refute_includes(actual, "--minify")
      end

      Tailwindcss::Commands.stub(:rails_css_compressor?, false) do
        actual = Tailwindcss::Commands.compile_command
        assert_kind_of(Array, actual)
        assert_includes(actual, "--minify")
      end
    end
  end

  test ".compile_command when postcss.config.js exists" do
    Dir.mktmpdir do |tmpdir|
      Rails.stub(:root, Pathname.new(tmpdir))  do # Rails.root won't work in this test suite
        actual = Tailwindcss::Commands.compile_command
        assert_kind_of(Array, actual)
        assert_equal(executable, actual.first)
        refute_includes(actual, "--postcss")

        config_file = Rails.root.join("postcss.config.js")
        FileUtils.touch(config_file)
        actual = Tailwindcss::Commands.compile_command
        assert_kind_of(Array, actual)
        assert_equal(executable, actual.first)
        assert_includes(actual, "--postcss")
        postcss_index = actual.index("--postcss")
        assert_equal(actual[postcss_index + 1], config_file.to_s)
      end
    end
  end

  test ".watch_command" do
    Rails.stub(:root, File) do # Rails.root won't work in this test suite
      actual = Tailwindcss::Commands.watch_command
      assert_kind_of(Array, actual)
      assert_equal(executable, actual.first)
      assert_includes(actual, "-w")
      refute_includes(actual, "-p")
      assert_includes(actual, "--minify")

      actual = Tailwindcss::Commands.watch_command(debug: true)
      assert_kind_of(Array, actual)
      assert_equal(executable, actual.first)
      assert_includes(actual, "-w")
      refute_includes(actual, "-p")
      refute_includes(actual, "--minify")

      actual = Tailwindcss::Commands.watch_command(always: true)
      assert_kind_of(Array, actual)
      assert_equal(executable, actual.first)
      assert_includes(actual, "-w")
      assert_includes(actual, "always")
    end
  end

  test ".watch restores the previous signal handlers when it exits" do
    signals = Tailwindcss::Commands::FORWARDED_SIGNALS
    original_handlers = signals.to_h { |signal| [signal, trap(signal, "DEFAULT")] }

    Rails.stub(:root, File) do # Rails.root won't work in this test suite
      handlers = signals.to_h { |signal| [signal, proc {}] }
      handlers.each { |signal, handler| trap(signal, handler) }

      Process.stub(:spawn, ->(*) { 999_999 }) do
        Process.stub(:wait, ->(*) {}) do
          Tailwindcss::Commands.watch
        end
      end

      handlers.each do |signal, handler|
        # trap returns the currently-installed handler, which should be ours.
        restored = trap(signal, handler)
        assert_same(handler, restored, "watch did not restore the #{signal} handler")
      end
    ensure
      original_handlers.each { |signal, handler| trap(signal, handler) }
    end
  end

  test ".watch forwards a stop signal to the spawned process so it isn't orphaned" do
    Dir.mktmpdir do |dir|
      ready_file = File.join(dir, "ready") # the fake watcher writes its pid here once running

      # Stand in for the real tailwindcss binary with a process we control: it
      # records its pid, then sleeps until a forwarded TERM makes it exit.
      fake_watcher = <<~RUBY
        Signal.trap("TERM") { exit(0) }
        File.write(#{ready_file.inspect}, Process.pid.to_s)
        sleep
      RUBY
      command = [RbConfig.ruby, "-e", fake_watcher]

      watcher_pid = nil

      # The stub must stay active across the fork so the forked watch picks up
      # our fake command instead of the real CLI.
      Tailwindcss::Commands.stub(:watch_command, ->(*) { command }) do
        watch_pid = fork do
          Tailwindcss::Commands.watch
        ensure
          # skip Minitest's at_exit in this forked child so it can't re-run the suite
          exit!(true)
        end

        begin
          assert(wait_until { File.size?(ready_file) }, "the spawned process never started")
          watcher_pid = Integer(File.read(ready_file))

          # SIGTERM the rake task, as a supervisor (foreman, systemd, Docker) would on shutdown.
          Process.kill("TERM", watch_pid)

          # Once watch is reaped it has waited out its child, so a live watcher means an orphan.
          assert(wait_until { reaped?(watch_pid) },
            "watch did not exit after its child did")
          refute(process_alive?(watcher_pid),
            "the spawned process #{watcher_pid} was orphaned after TERM")
        ensure
          # never leak the helper processes, even if an assertion above failed
          kill_quietly(watcher_pid)
          kill_quietly(watch_pid)
        end
      end
    end
  end

  private

  # Poll a condition until it's truthy or the deadline passes; returns the result.
  def wait_until(timeout: 10)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
    loop do
      result = yield
      if result
        return result
      elsif Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
        return false
      else
        sleep(0.05)
      end
    end
  end

  def process_alive?(pid)
    Process.kill(0, pid)
    true
  rescue Errno::ESRCH
    false
  rescue Errno::EPERM
    true
  end

  # True once pid has exited (reaping it), or if it was already reaped.
  def reaped?(pid)
    !!Process.wait(pid, Process::WNOHANG)
  rescue Errno::ECHILD
    true
  end

  # Kill and reap pid, tolerating a process that's already gone or isn't our child.
  def kill_quietly(pid)
    if pid
      begin
        Process.kill("KILL", pid)
      rescue Errno::ESRCH
        # already gone
      end
      begin
        Process.wait(pid)
      rescue Errno::ECHILD
        # not our child, or already reaped
      end
    end
  end
end
