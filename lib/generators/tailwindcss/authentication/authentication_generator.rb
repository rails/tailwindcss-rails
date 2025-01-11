require "rails/generators/erb/authentication/authentication_generator"

module Tailwindcss
  module Generators
    class AuthenticationGenerator < Erb::Generators::AuthenticationGenerator
      source_root File.expand_path("templates", __dir__)

      def copy_view_files
        template "../../scaffold/templates/_flashes.html.erb", "app/views/application/_flashes.html.erb"
      end
    end
  end
end
