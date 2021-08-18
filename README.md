# Tailwind CSS for Rails

[Tailwind CSS](https://tailwindcss.com) is a utility-first CSS framework packed with classes like flex, pt-4, text-center and rotate-90 that can be composed to build any design, directly in your markup.

This gem just gives access to the standard Tailwind CSS framework. If you need to customize Tailwind, you will need to install it the traditional way using [Webpacker](https://github.com/rails/webpacker) instead. This gem is purely intended for those who wish to use Tailwind CSS with the asset pipeline.

Production-mode purging of unused css class names is provided by a Sprockets compressor built into this gem. This compressor ensures that only the css classes used by files in `app/views` and `app/helpers` are included. In development mode, the full 3mb+ Tailwind stylesheet is loaded.

In both cases, Tailwind CSS is configured for dark mode, forms, aspect-ratio, typography, and the Inter font. If you need more configuration than that, you'll need to use it with Webpacker.


## Installation

1. Run `./bin/bundle add tailwindcss-rails`
2. Run `./bin/rails tailwindcss:install` (on a fresh Rails application)

The last step adds the purger compressor to `config/environments/production.rb`. This ensures that when `assets:precompile` is called during deployment that the unused class names are not included in the tailwind output css used by the app. It also adds a `stylesheet_link_tag "tailwind"` and `stylesheet_link_tag "inter-font"` to your `app/views/layouts/application.html.erb` file.

You can do these things yourself, if you've changed the default setup.


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
