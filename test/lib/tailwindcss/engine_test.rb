require "test_helper"

class Tailwindcss::EngineTest < ActiveSupport::TestCase
  # Simulates Propshaft::Helper#app_stylesheets_paths returning both
  # compiled output and engine stubs, then verifies the filter rejects stubs.
  test "filter_engine_stubs rejects paths starting with tailwind/" do
    helper_mod = Module.new do
      def app_stylesheets_paths
        ["application.css", "tailwind.css", "tailwind/my_engine.css", "tailwind/other_engine.css"]
      end
    end

    filter_mod = Module.new do
      def app_stylesheets_paths
        super.reject { |path| path.start_with?("tailwind/") }
      end
    end

    obj = Object.new
    obj.extend(helper_mod)
    obj.singleton_class.prepend(filter_mod)

    result = obj.app_stylesheets_paths
    assert_includes result, "tailwind.css", "Compiled output should pass through"
    assert_includes result, "application.css", "Non-tailwind assets should pass through"
    refute_includes result, "tailwind/my_engine.css", "Engine stubs should be filtered"
    refute_includes result, "tailwind/other_engine.css", "Engine stubs should be filtered"
  end

  test "filter_engine_stubs passes through when no engine stubs exist" do
    helper_mod = Module.new do
      def app_stylesheets_paths
        ["application.css", "tailwind.css"]
      end
    end

    filter_mod = Module.new do
      def app_stylesheets_paths
        super.reject { |path| path.start_with?("tailwind/") }
      end
    end

    obj = Object.new
    obj.extend(helper_mod)
    obj.singleton_class.prepend(filter_mod)

    assert_equal ["application.css", "tailwind.css"], obj.app_stylesheets_paths
  end
end
