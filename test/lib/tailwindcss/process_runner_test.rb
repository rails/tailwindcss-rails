require "test_helper"
require "minitest/mock"

class Tailwindcss::ProcessRunnerTest < ActiveSupport::TestCase
  test ".spawn_and_wait restores the previous signal handlers when it exits" do
    signals = Tailwindcss::ProcessRunner::FORWARDED_SIGNALS
    original_handlers = signals.to_h { |signal| [signal, trap(signal, "DEFAULT")] }

    begin
      handlers = signals.to_h { |signal| [signal, proc {}] }
      handlers.each { |signal, handler| trap(signal, handler) }

      Process.stub(:spawn, ->(*) { 999_999 }) do
        Process.stub(:wait, ->(*) {}) do
          Tailwindcss::ProcessRunner.spawn_and_wait({}, "tailwindcss")
        end
      end

      handlers.each do |signal, handler|
        # trap returns the currently-installed handler, which should be ours.
        restored = trap(signal, handler)
        assert_same(handler, restored, "spawn_and_wait did not restore the #{signal} handler")
      end
    ensure
      original_handlers.each { |signal, handler| trap(signal, handler) }
    end
  end

  test ".spawn_and_wait forwards a stop signal to the spawned process so it isn't orphaned" do
    Dir.mktmpdir do |dir|
      ready_file = File.join(dir, "ready") # the fake child writes its pid here once running

      # Stand in for the real tailwindcss binary with a process we control: it
      # records its pid, then sleeps until a forwarded TERM makes it exit.
      fake_watcher = <<~RUBY
        Signal.trap("TERM") { exit(0) }
        File.write(#{ready_file.inspect}, Process.pid.to_s)
        sleep
      RUBY
      command = [RbConfig.ruby, "-e", fake_watcher]

      watcher_pid = nil

      runner_pid = fork do
        Tailwindcss::ProcessRunner.spawn_and_wait({}, *command)
      ensure
        # skip Minitest's at_exit in this forked child so it can't re-run the suite
        exit!(true)
      end

      begin
        assert(wait_until { File.size?(ready_file) }, "the spawned process never started")
        watcher_pid = Integer(File.read(ready_file))

        # SIGTERM the runner, as a process manager (e.g. foreman) would on shutdown.
        Process.kill("TERM", runner_pid)

        # Once the runner is reaped it has waited out its child, so a live child means an orphan.
        assert(wait_until { reaped?(runner_pid) },
          "spawn_and_wait did not exit after its child did")
        refute(process_alive?(watcher_pid),
          "the spawned process #{watcher_pid} was orphaned after TERM")
      ensure
        # never leak the helper processes, even if an assertion above failed
        kill_quietly(watcher_pid)
        kill_quietly(runner_pid)
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
