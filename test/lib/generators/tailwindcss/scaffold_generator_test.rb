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

  [
    "lib/templates/tailwindcss/scaffold",
    "lib/templates/erb/scaffold",
  ].each do |templates_path|
    test "overriding generator templates in #{templates_path}" do
      override_dir = File.join(destination_root, templates_path)
      FileUtils.mkdir_p override_dir
      File.open(File.join(override_dir, "index.html.erb"), "w") { |f| f.puts "This is a custom template" }

      # change directory because the generator adds a relative path to source_paths
      Dir.chdir(destination_root) do
        run_generator
      end

      %w(edit new show _form _message).each do |view|
        assert_file "app/views/messages/#{view}.html.erb"
      end

      assert_file "app/views/messages/index.html.erb" do |body|
        assert_match("This is a custom template", body, "index custom template should be used")
      end
    end
  end
end
