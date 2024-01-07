require "test_helper"
require "generators/tailwindcss/scaffold/scaffold_generator"

class Tailwindcss::Generators::ScaffoldGeneratorTest < Rails::Generators::TestCase
  tests Tailwindcss::Generators::ScaffoldGenerator
  destination TAILWINDCSS_TEST_APP_ROOT

  arguments %w(message title:string content:text)

  test "generates view templates" do
    run_generator

    %w(index edit new show _form _message).each do |view|
      assert_file "app/views/messages/#{view}.html.erb"
    end
  end

  test "generates view templates with namespace" do
    run_generator [ "admin/role", "name:string", "description:string" ]

    %w(index edit new show _form _role).each do |view|
      assert_file "app/views/admin/roles/#{view}.html.erb"
    end
  end
end
