# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "rails"
require "rails/test_help"
require "byebug"
require_relative "../lib/tailwindcss-rails"

require "rails/test_unit/reporter"
Rails::TestUnitReporter.executable = 'bin/test'

class ActiveSupport::TestCase
  self.file_fixture_path = File.expand_path("fixtures/files", __dir__)
end
