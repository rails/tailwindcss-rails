# Tailwind CSS for Rails

[Tailwind CSS](https://tailwindcss.com) is a utility-first CSS framework packed with classes like flex, pt-4, text-center and rotate-90 that can be composed to build any design, directly in your markup.

Tailwind CSS for Rails works with both the asset pipeline and Webpacker.

When use with the asset pipeline, production-mode purging of unused css class names is provided by a Sprockets compressor built into this gem. This compressor ensures that only the css classes used by files in `app/views` and `app/helpers` are included. In development mode, the full 3mb+ Tailwind stylesheet is loaded. In both cases, Tailwind CSS is configured for dark mode, forms, aspect-ratio, typography, and the Inter font. If you need more configuration than that, you'll need to use it with Webpacker.

When used with Webpacker, Tailwind CSS is installed as a postCSS processor. Refer to the [TailwindCSS documentation](https://tailwindcss.com/docs/installation#customizing-your-configuration) to customize your tailwind.config.js file.


## Installation

1. Run `./bin/bundle add tailwindcss-rails`
2. Run `./bin/rails tailwindcss:install` (on a fresh Rails application)

When run on an app using the just the asset pipeline, the last step adds the purger compressor to `config/environments/production.rb`. This ensures that when `assets:precompile` is called during deployment that the unused class names are not included in the tailwind output css used by the app. It also adds a `stylesheet_link_tag "tailwind"` and `stylesheet_link_tag "inter-font"` to your `app/views/application.html.erb` file.

You can do these things yourself, if you've changed the default setup.

Note: You should ensure to delete `app/assets/stylesheets/scaffolds.scss` that Rails adds after running a scaffold command, if you had run this generator before installing Tailwind CSS for Rails. This stylesheet will interfere with Tailwind's reset of base styles. This gem will turn off stylesheet generation for all future scaffold runs.

When run on an app using Webpacker, the last step adds the npm dependencies for Tailwind CSS, configures postCSS, and generates a app/javascript/stylesheets/application.scss file as the default for using Tailwind.


## Purging in production

The Tailwind CSS framework starts out as a massive file, which gives you all the combinations of utility classes for development, but you wouldn't want to ship all those unused classes in production. So this gem includes a Sprockets compressor that purges the tailwind file from all those unused classes when Tailwind CSS for Rails is used with the asset pipeline.

This compressor is currently not compatible with the default Sprockets cache system due to the fact its output depends on files outside of Sprockets (all the files observed for utility class name usage), so this cache is disabled in production. If you need to disable it in other deployed environments, add the following to that environment configuration file:

```ruby
Rails.application.config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:null_store)
end
```


## Configuration

If you need to customize what files are searched for class names when using the asset pipeline, you need to replace the compressor line with something like:

```ruby
  config.assets.css_compressor = Tailwindcss::Compressor.new(files_with_class_names: Rails.root.glob("app/somewhere/**/*.*"))
```

By default, the CSS purger will only operate on the tailwind css file included with this gem. If you want to use it more broadly:

```ruby
  config.assets.css_compressor = Tailwindcss::Compressor.new(only_purge: %w[ tailwind and_my_other_css_file ])
```


## License

Tailwind for Rails is released under the [MIT License](https://opensource.org/licenses/MIT).
Tailwind CSS is released under the [MIT License](https://opensource.org/licenses/MIT).
The Inter font is released under the [SIL Open Font License, Version 1.1](https://github.com/rsms/inter/blob/master/LICENSE.txt).