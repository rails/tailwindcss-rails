ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]

require "rails"
require "rails/test_help"
require "debug"
require_relative "../lib/tailwindcss-rails"

require "rails/test_unit/reporter"
Rails::TestUnitReporter.executable = "bin/test"

class ActiveSupport::TestCase
  self.file_fixture_path = File.expand_path("fixtures/files", __dir__)
end

def with_files_with_class_names_configuration(new_value)
  old_value = Rails.application.config.tailwind.files_with_class_names
  Rails.application.config.tailwind.files_with_class_names = new_value
  yield
  Rails.application.config.tailwind.files_with_class_names = old_value
end
