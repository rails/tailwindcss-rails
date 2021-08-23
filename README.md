# Tailwind CSS for Rails

[Tailwind CSS](https://tailwindcss.com) is a utility-first CSS framework packed with classes like flex, pt-4, text-center and rotate-90 that can be composed to build any design, directly in your markup.

This gem gives access to the standard Tailwind CSS framework configured for dark mode, forms, aspect-ratio, typography, and the Inter font via the asset pipeline using Sprockets. If you need to customize Tailwind, you will need to install it the traditional way using [Webpacker](https://github.com/rails/webpacker) instead or use webpacker port of this gem [tailwindcss-rails-webpacker](https://github.com/WizardComputer/tailwindcss-rails-webpacker).

Production-mode purging of unused css class names is provided by a Sprockets compressor built into this gem. This compressor ensures that only the css classes used by files in `app/views` and `app/helpers` are included. In development mode, the full 7mb+ Tailwind stylesheet is loaded.


## Installation

1. Run `./bin/bundle add tailwindcss-rails`
2. Run `./bin/rails tailwindcss:install`

The last step adds the purger compressor to `config/environments/production.rb`. This ensures that when `assets:precompile` is called during deployment that the unused class names are not included in the tailwind output css used by the app. It also adds a `stylesheet_link_tag "tailwind"` and `stylesheet_link_tag "inter-font"` to your `app/views/layouts/application.html.erb` file.

You can do these things yourself, if you've changed the default setup.


## Purging in production

The Tailwind CSS framework starts out as a massive file, which gives you all the combinations of utility classes for development, but you wouldn't want to ship all those unused classes in production. So the Sprockets compressor included in this gem is used to purge the tailwind file from all those unused classes for production.

Note: This compressor is currently not compatible with the default Sprockets cache system due to the fact its output depends on files outside of Sprockets (all the files observed for utility class name usage), so this cache is disabled in production. If you need to disable it in other deployed environments, add the following to that environment configuration file:

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


## Tailwind versions

The Tailwind CSS main file that's being used before purging consists of these versions:

* @tailwindcss/aspect-ratio 0.2.1
* @tailwindcss/forms 0.3.3
* @tailwindcss/typography 0.4.1
* autoprefixer 10.3.1
* tailwindcss 2.2.7


## License

Tailwind for Rails is released under the [MIT License](https://opensource.org/licenses/MIT).
Tailwind CSS is released under the [MIT License](https://opensource.org/licenses/MIT).
The Inter font is released under the [SIL Open Font License, Version 1.1](https://github.com/rsms/inter/blob/master/LICENSE.txt).
