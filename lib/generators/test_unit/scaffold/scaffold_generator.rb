require "rails/generators/test_unit/scaffold/scaffold_generator"

module TestUnit # :nodoc:
  module Generators # :nodoc:
    class ScaffoldGenerator < Base # :nodoc:
      def fix_system_test
        system_test_file = File.join("test/system", class_path, "#{file_name.pluralize}_test.rb")
        if turbo_defined? && options[:system_tests] && File.exist?(system_test_file)
          gsub_file(system_test_file, /(click_on.*Destroy this.*)$/, "accept_confirm { \\1 }")
        end
      end

      private

      def turbo_defined?
        defined?(Turbo)
      end
    end
  end
end
