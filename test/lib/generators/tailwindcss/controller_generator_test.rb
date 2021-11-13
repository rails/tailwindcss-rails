require "test_helper"
require "generators/tailwindcss/controller/controller_generator"

class Tailwindcss::Generators::ControllerGeneratorTest < Rails::Generators::TestCase
  tests Tailwindcss::Generators::ControllerGenerator
  destination Dir.mktmpdir

  arguments %w(Messages index show)

  test "generates correct view templates" do
    run_generator
    assert_file "app/views/messages/index.html.erb"
    assert_file "app/views/messages/show.html.erb"
  end
end

