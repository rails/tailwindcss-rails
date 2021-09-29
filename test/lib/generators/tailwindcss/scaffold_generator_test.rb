require "test_helper"
require "generators/tailwindcss/scaffold/scaffold_generator"

class Tailwindcss::Generators::ScaffoldGeneratorTest < Rails::Generators::TestCase
  GENERATION_PATH = File.expand_path("../tmp", File.dirname(__FILE__))

  tests Tailwindcss::Generators::ScaffoldGenerator
  destination GENERATION_PATH

  arguments %w(message title:string content:text)

  Minitest.after_run do
    FileUtils.rm_rf GENERATION_PATH
  end

  test "generates correct view templates" do
    run_generator

    %w(index edit new show _form _message).each { |view| assert_file "app/views/messages/#{view}.html.erb" }
  end
end