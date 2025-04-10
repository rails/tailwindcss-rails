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
      actual = Tailwindcss::Commands.compile_command("app/assets/tailwind/application.css")
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

      actual = Tailwindcss::Commands.watch_command(poll: true)
      assert_kind_of(Array, actual)
      assert_equal(executable, actual.first)
      assert_includes(actual, "-w")
      refute_includes(actual, "always")
      assert_includes(actual, "-p")
      assert_includes(actual, "--minify")

      actual = Tailwindcss::Commands.watch_command(always: true)
      assert_kind_of(Array, actual)
      assert_equal(executable, actual.first)
      assert_includes(actual, "-w")
      assert_includes(actual, "always")
    end
  end

  test ".engines_tailwindcss_roots when there are no engines" do
    Rails.stub(:root, Pathname.new("/dummy")) do
      Rails::Engine.stub(:subclasses, []) do
        assert_empty Tailwindcss::Commands.engines_tailwindcss_roots
      end
    end
  end

  test ".engines_tailwindcss_roots when there are engines" do
    Dir.mktmpdir do |tmpdir|
      root = Pathname.new(tmpdir)

      # Create multiple engines
      engine_root1 = root.join('engine1')
      engine_root2 = root.join('engine2')
      engine_root3 = root.join('engine3')
      FileUtils.mkdir_p(engine_root1)
      FileUtils.mkdir_p(engine_root2)
      FileUtils.mkdir_p(engine_root3)

      engine1 = Class.new(Rails::Engine) do
        define_singleton_method(:engine_name) { "test_engine1" }
        define_singleton_method(:root) { engine_root1 }
      end

      engine2 = Class.new(Rails::Engine) do
        define_singleton_method(:engine_name) { "test_engine2" }
        define_singleton_method(:root) { engine_root2 }
      end

      engine3 = Class.new(Rails::Engine) do
        define_singleton_method(:engine_name) { "test_engine3" }
        define_singleton_method(:root) { engine_root3 }
      end

      # Create mock specs for engines
      spec1 = Minitest::Mock.new
      spec1.expect(:dependencies, [Gem::Dependency.new("tailwindcss-rails")])

      spec2 = Minitest::Mock.new
      spec2.expect(:dependencies, [Gem::Dependency.new("tailwindcss-rails")])

      spec3 = Minitest::Mock.new
      spec3.expect(:dependencies, [])

      # Set up file structure
      # Engine 1: CSS in engine root
      engine1_css = engine_root1.join("app/assets/tailwind/test_engine1/application.css")
      FileUtils.mkdir_p(File.dirname(engine1_css))
      FileUtils.touch(engine1_css)

      # Engine 2: CSS in Rails root
      engine2_css = root.join("app/assets/tailwind/test_engine2/application.css")
      FileUtils.mkdir_p(File.dirname(engine2_css))
      FileUtils.touch(engine2_css)

      # Engine 3: CsS in engine root, but no tailwindcss-rails dependency
      engine3_css = engine_root2.join("app/assets/tailwind/test_engine3/application.css")
      FileUtils.mkdir_p(File.dirname(engine3_css))
      FileUtils.touch(engine3_css)

      find_by_name_results = {
        "test_engine1" => spec1,
        "test_engine2" => spec2,
        "test_engine3" => spec3,
      }

      Gem::Specification.stub(:find_by_name, ->(name) { find_by_name_results[name] }) do
        Rails.stub(:root, root) do
          Rails::Engine.stub(:subclasses, [engine1, engine2]) do
            roots = Tailwindcss::Commands.engines_tailwindcss_roots

            assert_equal 2, roots.size
            assert_includes roots, engine1_css.to_s
            assert_includes roots, engine2_css.to_s
            assert_not_includes roots, engine3_css.to_s
          end
        end
      end

      spec1.verify
      spec2.verify
    end
  end

  test ".with_dynamic_input when there are no engines" do
    Dir.mktmpdir do |tmpdir|
      root = Pathname.new(tmpdir)
      input_path = root.join("app/assets/tailwind/application.css").to_s

      Rails.stub(:root, root) do
        Tailwindcss::Commands.stub(:engines_tailwindcss_roots, []) do
          Tailwindcss::Commands.with_dynamic_input do |actual|
            assert_equal input_path, actual
          end
        end
      end
    end
  end

  test ".with_dynamic_input when there are engines" do
    Dir.mktmpdir do |tmpdir|
      root = Pathname.new(tmpdir)
      input_path = root.join("app/assets/tailwind/application.css").to_s

      # Create necessary files
      FileUtils.mkdir_p(File.dirname(input_path))
      FileUtils.touch(input_path)

      # Create engine CSS file
      engine_css_path = root.join("app/assets/tailwind/test_engine/application.css")
      FileUtils.mkdir_p(File.dirname(engine_css_path))
      FileUtils.touch(engine_css_path)

      Rails.stub(:root, root) do
        Tailwindcss::Commands.stub(:engines_tailwindcss_roots, [engine_css_path.to_s]) do
          Tailwindcss::Commands.with_dynamic_input do |actual|
            temp_path = Pathname.new(actual)
            refute_equal input_path, temp_path.to_s  # input path should be different
            assert_match(/tailwind\.css/, temp_path.basename.to_s)  # should use temp file
            assert_includes [Dir.tmpdir, '/tmp'], temp_path.dirname.to_s  # should be in temp directory

            # Check temp file contents
            temp_content = File.read(actual)
            expected_content = <<~CSS
            @import "#{engine_css_path}";
            @import "#{input_path}";
          CSS
            assert_equal expected_content.strip, temp_content.strip
          end
        end
      end
    end
  end
end
