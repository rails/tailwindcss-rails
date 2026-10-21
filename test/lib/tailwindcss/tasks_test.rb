require "test_helper"
require "rake"

class Tailwindcss::TasksTest < ActiveSupport::TestCase
  def setup
    super
    @root = Pathname.new(TAILWINDCSS_TEST_APP_ROOT).join("path with spaces")
    @app = @root.join("app")
    @argv_path = @root.join("argv.json")

    # put a copy of the task files under a directory with spaces, the same way
    # they'd be loaded from a gem installed under such a directory
    FileUtils.mkdir_p(@root.join("gem/lib/tasks"))
    %w[install upgrade].each do |name|
      FileUtils.cp(File.expand_path("../../../lib/tasks/#{name}.rake", __dir__), @root.join("gem/lib/tasks"))
    end

    # a fake bin/rails that records the arguments it was called with
    FileUtils.mkdir_p(@app.join("bin"))
    File.write(@app.join("bin/rails"), <<~RUBY)
      require "json"
      File.write(#{@argv_path.to_s.inspect}, JSON.generate(ARGV))
    RUBY
  end

  test "install passes the template location as a single argument" do
    run_task("install")

    assert_equal(
      ["app:template", "LOCATION=#{@root.join("gem/lib/install/install_tailwindcss.rb")}"],
      JSON.parse(File.read(@argv_path))
    )
  end

  test "upgrade passes the template location as a single argument" do
    run_task("upgrade")

    assert_equal(
      ["app:template", "LOCATION=#{@root.join("gem/lib/install/upgrade_tailwindcss.rb")}"],
      JSON.parse(File.read(@argv_path))
    )
  end

  private
    def run_task(name)
      rake = Rake::Application.new
      previous, Rake.application = Rake.application, rake
      load @root.join("gem/lib/tasks/#{name}.rake").to_s
      Dir.chdir(@app) { rake["tailwindcss:#{name}"].invoke }
    ensure
      Rake.application = previous
    end
end
