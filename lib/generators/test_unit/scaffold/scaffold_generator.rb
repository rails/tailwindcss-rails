require "rails/generators/test_unit/scaffold/scaffold_generator"

module TestUnit # :nodoc:
  module Generators # :nodoc:
    class ScaffoldGenerator < Base # :nodoc:
      def fix_system_test
        if system_tests_enabled? && turbo_defined?
          gsub_file File.join("test/system", class_path, "#{file_name.pluralize}_test.rb"),
                    /(click_on.*Destroy this.*)$/,
                    "accept_confirm { \\1 }"
        end
      end

      private

      def turbo_defined?
        defined?(Turbo)
      end

      def system_tests_enabled?
        defined?(Rails.configuration.generators) && Rails.configuration.generators.system_tests
      end
    end
  end
end
