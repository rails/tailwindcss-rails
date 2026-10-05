require "test_helper"

class BuildRakeTest < ActiveSupport::TestCase
  BUILD_RAKE = File.expand_path("../../../../lib/tasks/build.rake", __FILE__)

  # Rake tasks are global singletons, so we can't load build.rake into the test
  # process and inspect prerequisites without polluting other tests (and we'd
  # only ever see one value of the env var per process). Instead we shell out to
  # a fresh Ruby process that stubs the tasks build.rake expects to already
  # exist, loads build.rake, and prints the resulting prerequisites.
  def prerequisites_for(env: {})
    script = <<~RUBY
      require "bundler/setup"
      require "rake"
      require "active_support/all"

      Rake::Task.define_task("environment")
      Rake::Task.define_task("assets:precompile")
      Rake::Task.define_task("test:prepare")

      load #{BUILD_RAKE.inspect}

      puts Rake::Task["assets:precompile"].prerequisites.inspect
      puts Rake::Task["test:prepare"].prerequisites.inspect
    RUBY

    output = IO.popen(env, [Gem.ruby, "-e", script], &:read)
    assert $?.success?, "subprocess failed:\n#{output}"

    assets_precompile, test_prepare = output.lines.map { |line| eval(line) } # rubocop:disable Security/Eval
    { "assets:precompile" => assets_precompile, "test:prepare" => test_prepare }
  end

  test "tailwindcss:build is attached to assets:precompile and test:prepare by default" do
    prerequisites = prerequisites_for(env: {})

    assert_includes prerequisites["assets:precompile"], "tailwindcss:build"
    assert_includes prerequisites["test:prepare"], "tailwindcss:build"
  end

  test "TAILWINDCSS_SKIP_BUILD skips attaching tailwindcss:build" do
    prerequisites = prerequisites_for(env: { "TAILWINDCSS_SKIP_BUILD" => "1" })

    refute_includes prerequisites["assets:precompile"], "tailwindcss:build"
    refute_includes prerequisites["test:prepare"], "tailwindcss:build"
  end

  test "a blank TAILWINDCSS_SKIP_BUILD does not skip the build" do
    prerequisites = prerequisites_for(env: { "TAILWINDCSS_SKIP_BUILD" => "" })

    assert_includes prerequisites["assets:precompile"], "tailwindcss:build"
    assert_includes prerequisites["test:prepare"], "tailwindcss:build"
  end
end
