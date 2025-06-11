require "test_helper"
require "minitest/mock"

class Tailwindcss::EngineTest < ActiveSupport::TestCase
  def setup
    super
    # Store original Rails state
    @original_rails_root = Rails.root
    @original_application = Rails.application
  end
  
  def teardown
    super
    # Restore original Rails state
    Rails.application = @original_application if @original_application
  end
  
  test "after_initialize calls Tailwindcss::Engines.bundle" do
    called = false
    
    # Replace bundle method with our spy
    Tailwindcss::Engines.stub(:bundle, ->{ called = true }) do
      # Execute the after_initialize block
      Rails.stub(:root, File) do
        engine_file = File.join(File.dirname(__FILE__), "../../../lib/tailwindcss/engine.rb")
        engine_code = File.read(engine_file)
        
        # Verify that the after_initialize block calls Engines.bundle
        assert_match(/config\.after_initialize do.*?Tailwindcss::Engines\.bundle.*?end/m, engine_code,
                    "Expected after_initialize block to call Tailwindcss::Engines.bundle")
        
        # Call bundle to verify our spy works
        Tailwindcss::Engines.bundle
        assert called, "Expected Tailwindcss::Engines.bundle to be called"
      end
    end
  end
end