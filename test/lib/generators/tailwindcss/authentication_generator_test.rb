require "test_helper"

if Rails::VERSION::MAJOR >= 8
  require "generators/tailwindcss/authentication/authentication_generator"

  class Tailwindcss::Generators::AuthenticationGeneratorTest < Rails::Generators::TestCase
    tests Tailwindcss::Generators::AuthenticationGenerator
    destination TAILWINDCSS_TEST_APP_ROOT

    test "generates the new session template" do
      run_generator

      assert_file "app/views/sessions/new.html.erb"
    end
  end
end
