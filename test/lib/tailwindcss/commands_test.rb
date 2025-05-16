require "test_helper"
require "minitest/mock"

class Tailwindcss::CommandsTest < ActiveSupport::TestCase
  attr_accessor :executable, :original_rails, :tmp_dir

  setup do
    @tmp_dir = Dir.mktmpdir
    @original_rails = Object.const_get(:Rails) if Object.const_defined?(:Rails)
    @executable = Tailwindcss::Ruby.executable
  end

  teardown do
    FileUtils.rm_rf(@tmp_dir)
    Tailwindcss::Commands.remove_tempfile! if Tailwindcss::Commands.class_variable_defined?(:@@tempfile)
    restore_rails_constant
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

  test ".engines_roots when Rails is not defined" do
    Object.send(:remove_const, :Rails) if Object.const_defined?(:Rails)
    assert_empty Tailwindcss::Commands.engines_roots
  end

  test ".engines_roots when no engines are configured" do
    with_rails_app do
      assert_empty Tailwindcss::Commands.engines_roots
    end
  end

  test ".engines_roots when there are engines" do
    within_engine_configs do |engine1, engine2, engine3|
      roots = Tailwindcss::Commands.engines_roots

      assert_equal 2, roots.size
      assert_includes roots, engine1.css_path.to_s
      assert_includes roots, engine2.css_path.to_s
      refute_includes roots, engine3.css_path.to_s
    end
  end

  test ".with_dynamic_input yields tempfile path when engines exist" do
    within_engine_configs do |engine1, engine2|
      Tailwindcss::Commands.with_dynamic_input do |css_path|
        assert_match(/tailwind\.css/, css_path)
        assert File.exist?(css_path)

        content = File.read(css_path)
        assert_match %r{@import "#{engine1.css_path}";}, content
        assert_match %r{@import "#{engine2.css_path}";}, content
        assert_match %r{@import "#{Rails.root.join('app/assets/tailwind/application.css')}";}, content
      end
    end
  end

  test ".with_dynamic_input yields application.css path when no engines" do
    with_rails_app do
      expected_path = Rails.root.join("app/assets/tailwind/application.css").to_s
      Tailwindcss::Commands.with_dynamic_input do |css_path|
        assert_equal expected_path, css_path
      end
    end
  end

  test "engines can be configured via tailwindcss_rails.engines" do
    with_rails_app do
      # Create a test engine
      test_engine = Class.new(Rails::Engine) do
        def self.engine_name
          "test_engine"
        end

        def self.root
          Pathname.new(Dir.mktmpdir)
        end
      end

      # Create CSS file for the engine
      engine_css_path = test_engine.root.join("app/assets/tailwind/test_engine/application.css")
      FileUtils.mkdir_p(File.dirname(engine_css_path))
      FileUtils.touch(engine_css_path)

      # Create application-level CSS file
      app_css_path = Rails.root.join("app/assets/tailwind/test_engine/application.css")
      FileUtils.mkdir_p(File.dirname(app_css_path))
      FileUtils.touch(app_css_path)

      # Register the engine
      Rails::Engine.descendants << test_engine

      # Store the hook for later execution
      hook = nil
      ActiveSupport.on_load(:tailwindcss_rails) do
        hook = self
        Rails.application.config.tailwindcss_rails.engines << "test_engine"
      end

      # Trigger the hook manually
      ActiveSupport.run_load_hooks(:tailwindcss_rails, hook)

      # Verify the engine is included in roots
      roots = Tailwindcss::Commands.engines_roots
      assert_equal 1, roots.size
      assert_includes roots, app_css_path.to_s
    ensure
      FileUtils.rm_rf(test_engine.root) if defined?(test_engine)
      FileUtils.rm_rf(File.dirname(app_css_path)) if defined?(app_css_path)
    end
  end

  private
    # Define Structs outside of methods to avoid redefining them
    ConfigStruct = Struct.new(:engines)
    AssetsStruct = Struct.new(:css_compressor)
    TailwindStruct = Struct.new(:tailwindcss_rails, :assets)
    AppStruct = Struct.new(:config)
    EngineStruct = Struct.new(:name, :root, :css_path)

    def with_rails_app
      Object.send(:remove_const, :Rails) if Object.const_defined?(:Rails)
      Object.const_set(:Rails, setup_mock_rails)
      yield
    end

    def setup_mock_rails
      mock_engine = Class.new do
        class << self
          attr_accessor :engine_name, :root

          def descendants
            @descendants ||= []
          end
        end
      end

      mock_rails = Class.new do
        class << self
          attr_accessor :root, :application

          def const_get(const_name)
            return Engine if const_name == :Engine
            super
          end
        end
      end

      mock_rails.const_set(:Engine, mock_engine)
      mock_rails.root = Pathname.new(@tmp_dir)
      tailwind_config = ConfigStruct.new([])
      assets_config = AssetsStruct.new(nil)
      app_config = TailwindStruct.new(tailwind_config, assets_config)
      mock_rails.application = AppStruct.new(app_config)
      mock_rails
    end

    def restore_rails_constant
      Object.send(:remove_const, :Rails) if Object.const_defined?(:Rails)
      Object.const_set(:Rails, @original_rails) if @original_rails
    end

    def within_engine_configs
      engine_configs = create_test_engines
      with_rails_app do
        Rails.application.config.tailwindcss_rails.engines = %w[test_engine1 test_engine2]

        # Create and register mock engine classes
        engine_configs.each do |config|
          engine_class = Class.new(Rails::Engine)
          engine_class.engine_name = config.name
          engine_class.root = Pathname.new(config.root)
          Rails::Engine.descendants << engine_class
        end

        yield(*engine_configs)
      end
    end

    def create_test_engines
      [1, 2, 3].map do |i|
        engine = EngineStruct.new(
          "test_engine#{i}",
          File.join(@tmp_dir, "engine#{i}"),
          File.join(@tmp_dir, "app/assets/tailwind/test_engine#{i}/application.css")
        )
        FileUtils.mkdir_p(File.dirname(engine.css_path))
        FileUtils.touch(engine.css_path)
        engine
      end
    end
end
