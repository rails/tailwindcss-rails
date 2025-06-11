require "test_helper"
require "minitest/mock"

class Tailwindcss::EnginesTest < ActiveSupport::TestCase
  def setup
    super
    @tmpdir_path = Pathname.new(Dir.mktmpdir)
    @builds_dir = @tmpdir_path.join("app/assets/builds/tailwind")
  end

  test "bundle creates the builds directory" do
    Rails.stub(:root, @tmpdir_path) do
      Tailwindcss::Engines.bundle
      assert Dir.exist?(@builds_dir), "Expected directory #{@builds_dir} to be created"
    end
  end

  test "bundle generates CSS files for engine's tailwind assets" do
    Rails.stub(:root, @tmpdir_path) do
      setup_mock_engine("mock_engine", @tmpdir_path)

      Tailwindcss::Engines.bundle

      css_file_path = @builds_dir.join("mock_engine.css")
      assert File.exist?(css_file_path), "Expected file #{css_file_path} to be created"

      content = File.read(css_file_path)
      assert_match(/DO NOT MODIFY THIS FILE/, content)
      assert_match(/@import ".*\/app\/assets\/tailwind\/mock_engine\/engine.css"/, content)
    end
  end

  test "bundle removes existing files before generating new ones" do
    Rails.stub(:root, @tmpdir_path) do
      setup_mock_engine("mock_engine", @tmpdir_path)

      FileUtils.mkdir_p(@builds_dir)
      css_file_path = @builds_dir.join("mock_engine.css")
      File.write(css_file_path, "OLD CONTENT")

      Tailwindcss::Engines.bundle

      content = File.read(css_file_path)
      assert_no_match(/OLD CONTENT/, content)
      assert_match(/DO NOT MODIFY THIS FILE/, content)
    end
  end

  test "bundle only processes engines with tailwind assets" do
    Rails.stub(:root, @tmpdir_path) do
      setup_mock_engine("engine_with_assets", @tmpdir_path)

      Class.new(Rails::Engine) do
        define_singleton_method(:engine_name) { "engine_without_assets" }
        define_singleton_method(:root) { Pathname.new(Dir.mktmpdir) }
      end

      Tailwindcss::Engines.bundle

      assert File.exist?(@builds_dir.join("engine_with_assets.css")), "Expected CSS file for engine with assets"
      refute File.exist?(@builds_dir.join("engine_without_assets.css")), "Expected no CSS file for engine without assets"
    end
  end

  test "bundle handles multiple engines" do
    Rails.stub(:root, @tmpdir_path) do
      setup_mock_engine("engine1", @tmpdir_path)
      setup_mock_engine("engine2", @tmpdir_path)

      Tailwindcss::Engines.bundle

      assert File.exist?(@builds_dir.join("engine1.css")), "Expected CSS file for engine1"
      assert File.exist?(@builds_dir.join("engine2.css")), "Expected CSS file for engine2"
    end
  end

  private

  def setup_mock_engine(name, root_path)
    tailwind_dir = root_path.join("app/assets/tailwind/#{name}")
    FileUtils.mkdir_p(tailwind_dir)
    File.write(tailwind_dir.join("engine.css"), "/* Test CSS */")

    Class.new(Rails::Engine) do
      define_singleton_method(:engine_name) { name }
      define_singleton_method(:root) { root_path.dup }
    end
  end
end
