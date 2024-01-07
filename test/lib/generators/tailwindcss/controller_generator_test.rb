require "test_helper"
require "generators/tailwindcss/controller/controller_generator"

class Tailwindcss::Generators::ControllerGeneratorTest < Rails::Generators::TestCase
  tests Tailwindcss::Generators::ControllerGenerator
  destination TAILWINDCSS_TEST_APP_ROOT

  arguments %w(Messages index show)

  test "generates correct view templates" do
    run_generator

    ["index", "show"].each do |view|
      assert_file "app/views/messages/#{view}.html.erb"
    end
  end

  test "generates correct view templates when namespaced" do
    run_generator ["admin/messages", "index", "show"]

    ["index", "show"].each do |view|
      assert_file "app/views/admin/messages/#{view}.html.erb"
    end
  end

  [
    "lib/templates/erb/controller",
    "lib/templates/tailwindcss/controller",
  ].each do |templates_path|
    test "overriding generator templates in #{templates_path}" do
      override_dir = File.join(destination_root, templates_path)
      FileUtils.mkdir_p override_dir
      File.open(File.join(override_dir, "view.html.erb"), "w") { |f| f.puts "This is a custom template" }

      # change directory because the generator adds a relative path to source_paths
      Dir.chdir(destination_root) do
        run_generator
      end

      ["index", "show"].each do |view|
        assert_file "app/views/messages/#{view}.html.erb" do |body|
          assert_match("This is a custom template", body, "index custom template should be used")
        end
      end
    end
  end
end
