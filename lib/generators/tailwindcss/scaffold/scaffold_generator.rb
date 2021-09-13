require 'rails/generators/erb/scaffold/scaffold_generator'
require "rails/generators/resource_helpers"

module Tailwindcss
  module Generators
    class ScaffoldGenerator < Erb::Generators::ScaffoldGenerator
      include Rails::Generators::ResourceHelpers

      source_root File.expand_path("../templates", __FILE__)

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      def create_root_folder
        empty_directory File.join("app/views", controller_file_path)
      end

      def copy_view_files
        available_views.each do |view|
          formats.each do |format|
            filename = filename_with_extensions(view, format)
            template filename, File.join("app/views", controller_file_path, filename)
          end
        end

        template "partial.html.erb", File.join("app/views", controller_file_path, "_#{singular_table_name}.html.erb")
      end

      private
        def available_views
          %w(index edit show new _form)
        end
    end
  end
end