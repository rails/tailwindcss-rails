require "test_helper"

class Tailwindcss::EnginesTest < ActiveSupport::TestCase
  def setup
    super
    # Store original Rails state
    @original_rails_root = Rails.root
    @original_application = Rails.application
    @test_app_root = Pathname.new(TAILWINDCSS_TEST_APP_ROOT)
    
    # Set up directories
    @builds_dir = @test_app_root.join("app/assets/builds/tailwind")
    FileUtils.rm_rf(@builds_dir) if Dir.exist?(@builds_dir)
    
    # Save original subclasses to restore later
    @original_subclasses = Rails::Engine.subclasses.dup
  end

  def teardown
    super
    # Restore original state
    Rails.application = @original_application if @original_application
    
    # If we've modified the Rails::Engine subclasses, restore them
    if @original_subclasses
      Rails::Engine.instance_variable_set(:@subclasses, @original_subclasses)
    end
    
    # Clean up test directory
    FileUtils.rm_rf(@builds_dir) if Dir.exist?(@builds_dir)
  end

  test "bundle creates the builds directory" do
    # Store the original Rails application for restoration later
    original_app = Rails.application
    
    Dir.mktmpdir do |tmpdir|
      @tmpdir = tmpdir
      tmpdir_path = Pathname.new(tmpdir)
      builds_dir = tmpdir_path.join("app/assets/builds/tailwind")

      Rails.stub(:root, tmpdir_path) do
        # Execute the bundle method
        Tailwindcss::Engines.bundle

        # Assert that the directory was created
        assert Dir.exist?(builds_dir), "Expected directory #{builds_dir} to be created"
      end
    end
    
    # Restore the original Rails application
    Rails.application = original_app
  end
  
  test "bundle generates CSS files for engine's tailwind assets" do
    # Store the original Rails application and engine subclasses
    original_app = Rails.application
    original_subclasses = Rails::Engine.subclasses.dup
    
    Dir.mktmpdir do |tmpdir|
      @tmpdir = tmpdir
      tmpdir_path = Pathname.new(tmpdir)
      builds_dir = tmpdir_path.join("app/assets/builds/tailwind")

      Rails.stub(:root, tmpdir_path) do
        # Create a mock engine with tailwind assets
        setup_mock_engine("mock_engine", tmpdir_path)
        
        # Execute the bundle method
        Tailwindcss::Engines.bundle
        
        # Assert that the CSS file was generated
        css_file_path = builds_dir.join("mock_engine.css")
        assert File.exist?(css_file_path), "Expected file #{css_file_path} to be created"
        
        # Check content of the generated file
        content = File.read(css_file_path)
        assert_match(/DO NOT MODIFY THIS FILE/, content)
        assert_match(/@import ".*\/app\/assets\/tailwind\/mock_engine\/application.css"/, content)
      end
    end
    
    # Restore the original Rails application and engine subclasses
    Rails.application = original_app
    Rails::Engine.instance_variable_set(:@subclasses, original_subclasses)
  end
  
  test "bundle removes existing files before generating new ones" do
    # Store the original Rails application and engine subclasses
    original_app = Rails.application
    original_subclasses = Rails::Engine.subclasses.dup
    
    Dir.mktmpdir do |tmpdir|
      @tmpdir = tmpdir
      tmpdir_path = Pathname.new(tmpdir)
      builds_dir = tmpdir_path.join("app/assets/builds/tailwind")

      Rails.stub(:root, tmpdir_path) do
        # Create a mock engine with tailwind assets
        setup_mock_engine("mock_engine", tmpdir_path)
        
        # Create an existing file that should be replaced
        FileUtils.mkdir_p(builds_dir)
        css_file_path = builds_dir.join("mock_engine.css")
        File.write(css_file_path, "OLD CONTENT")
        
        # Execute the bundle method
        Tailwindcss::Engines.bundle
        
        # Assert that the old content was removed
        content = File.read(css_file_path)
        assert_no_match(/OLD CONTENT/, content)
        assert_match(/DO NOT MODIFY THIS FILE/, content)
      end
    end
    
    # Restore the original Rails application and engine subclasses
    Rails.application = original_app
    Rails::Engine.instance_variable_set(:@subclasses, original_subclasses)
  end
  
  test "bundle only processes engines with tailwind assets" do
    # Store the original Rails application and engine subclasses
    original_app = Rails.application
    original_subclasses = Rails::Engine.subclasses.dup
    
    Dir.mktmpdir do |tmpdir|
      @tmpdir = tmpdir
      tmpdir_path = Pathname.new(tmpdir)
      builds_dir = tmpdir_path.join("app/assets/builds/tailwind")

      Rails.stub(:root, tmpdir_path) do
        # Create a mock engine with tailwind assets
        setup_mock_engine("engine_with_assets", tmpdir_path)
        
        # Create a mock engine without tailwind assets
        root_path = tmpdir_path
        mock_engine_without_assets = Class.new(Rails::Engine) do
          define_singleton_method(:engine_name) { "engine_without_assets" }
          define_singleton_method(:root) { root_path }
        end
        Rails::Engine.instance_variable_set(:@subclasses, Rails::Engine.subclasses + [mock_engine_without_assets])
        
        # Execute the bundle method
        Tailwindcss::Engines.bundle
        
        # Assert that only the engine with assets has a CSS file generated
        assert File.exist?(builds_dir.join("engine_with_assets.css")), "Expected CSS file for engine with assets"
        refute File.exist?(builds_dir.join("engine_without_assets.css")), "Expected no CSS file for engine without assets"
      end
    end
    
    # Restore the original Rails application and engine subclasses
    Rails.application = original_app
    Rails::Engine.instance_variable_set(:@subclasses, original_subclasses)
  end
  
  test "bundle handles multiple engines" do
    # Store the original Rails application and engine subclasses
    original_app = Rails.application
    original_subclasses = Rails::Engine.subclasses.dup
    
    Dir.mktmpdir do |tmpdir|
      @tmpdir = tmpdir
      tmpdir_path = Pathname.new(tmpdir)
      builds_dir = tmpdir_path.join("app/assets/builds/tailwind")

      Rails.stub(:root, tmpdir_path) do
        # Create multiple mock engines with tailwind assets
        setup_mock_engine("engine1", tmpdir_path)
        setup_mock_engine("engine2", tmpdir_path)
        
        # Execute the bundle method
        Tailwindcss::Engines.bundle
        
        # Assert that CSS files were generated for both engines
        assert File.exist?(builds_dir.join("engine1.css")), "Expected CSS file for engine1"
        assert File.exist?(builds_dir.join("engine2.css")), "Expected CSS file for engine2"
      end
    end
    
    # Restore the original Rails application and engine subclasses
    Rails.application = original_app
    Rails::Engine.instance_variable_set(:@subclasses, original_subclasses)
  end
  
  private
  
  def setup_mock_engine(name, root_path)
    # Create a mock Rails engine with captured local variables
    engine_name = name
    path = root_path
    mock_engine = Class.new(Rails::Engine) do
      define_singleton_method(:engine_name) { engine_name }
      define_singleton_method(:root) { path }
    end
    
    # Create the required tailwind asset file for the mock engine
    tailwind_dir = root_path.join("app/assets/tailwind/#{name}")
    FileUtils.mkdir_p(tailwind_dir)
    File.write(tailwind_dir.join("application.css"), "/* Test CSS */")
    
    # Add the mock engine to Rails::Engine.subclasses
    Rails::Engine.instance_variable_set(:@subclasses, Rails::Engine.subclasses + [mock_engine])
    
    mock_engine
  end
end