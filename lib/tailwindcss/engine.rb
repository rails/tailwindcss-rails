require "rails"

module Tailwindcss
  class Engine < ::Rails::Engine
    initializer "tailwindcss.disable_generator_stylesheets" do
      Rails.application.config.generators.stylesheets = false
    end

    initializer "tailwindcss.exclude_asset_path", before: "propshaft.append_assets_path" do
      if Rails.application.config.assets.excluded_paths # the app may not be using Propshaft
        Rails.application.config.assets.excluded_paths << Rails.root.join("app/assets/tailwind")
      end
    end

    # Filter engine CSS stubs from Propshaft's :app stylesheet resolution.
    #
    # The tailwindcss:engines task generates intermediate stub files at
    # app/assets/builds/tailwind/<engine>.css containing @import directives
    # with absolute filesystem paths. These are consumed by the Tailwind CLI
    # at build time and inlined into the compiled tailwind.css output.
    #
    # When hosts use stylesheet_link_tag :app (the Rails 8.1 default),
    # Propshaft globs app/assets/**/*.css and serves these stubs directly
    # to the browser. The browser interprets the absolute path as a URL
    # and gets a 404.
    #
    # Propshaft's excluded_paths can't help here — it only filters top-level
    # load path directories, not subdirectories within a load path.
    initializer "tailwindcss.filter_engine_stubs" do
      ActiveSupport.on_load(:action_view) do
        if defined?(Propshaft::Helper)
          Propshaft::Helper.prepend(Module.new {
            def app_stylesheets_paths
              super.reject { |path| path.start_with?("tailwind/") }
            end
          })
        end
      end
    end

    config.app_generators do |g|
      g.template_engine :tailwindcss
    end
  end
end
