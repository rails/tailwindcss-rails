require "test_helper"
require "generators/tailwindcss/scaffold/scaffold_generator"

class Tailwindcss::Generators::ScaffoldGeneratorTest < Rails::Generators::TestCase
  tests Tailwindcss::Generators::ScaffoldGenerator
  destination Dir.mktmpdir

  arguments %w(message title:string content:text)

  test "generates correct view templates" do
    run_generator

    %w(index edit new show _form _message).each { |view| assert_file "app/views/messages/#{view}.html.erb" }
  end
end
