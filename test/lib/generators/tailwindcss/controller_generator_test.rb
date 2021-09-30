require "test_helper"
require "generators/tailwindcss/controller/controller_generator"

class Tailwindcss::Generators::ControllerGeneratorTest < Rails::Generators::TestCase
  GENERATION_PATH = File.expand_path("../controller_tmp", File.dirname(__FILE__))

  tests Tailwindcss::Generators::ControllerGenerator
  destination GENERATION_PATH

  arguments %w(Messages index show)

   Minitest.after_run do
     FileUtils.rm_rf GENERATION_PATH
   end

  test "generates correct view templates" do
    run_generator
    assert_file "app/views/messages/index.html.erb"
    assert_file "app/views/messages/show.html.erb"
  end
end

