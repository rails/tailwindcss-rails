require "test_helper"

class Tailwindcss::CompressorTest < ActiveSupport::TestCase
  test "files_with_class_names on default configuration" do
    default_files_with_class_names = Rails.root.glob("app/views/**/*.*") + Rails.root.glob("app/helpers/**/*.rb")

    assert_equal default_files_with_class_names, Tailwindcss::Compressor.new.instance_variable_get(:@options)[:files_with_class_names]
  end

  test "files_with_class_names on custom configuration" do
    files_with_class_names = Rails.application.config.tailwind.files_with_class_names + Rails.root.glob("app/custom_views/**/*.*")
    with_files_with_class_names_configuration(files_with_class_names) do
      assert_equal files_with_class_names, Tailwindcss::Compressor.new.instance_variable_get(:@options)[:files_with_class_names]
    end
  end
end
