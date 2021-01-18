# Tailwind CSS for Rails

[Tailwind CSS](https://tailwindcss.com) is a utility-first CSS framework packed with classes like flex, pt-4, text-center and rotate-90 that can be composed to build any design, directly in your markup.

Tailwind CSS for Rails makes it easy to use this CSS framework with the asset pipeline. In development mode, the full 3mb+ Tailwind stylsheet is loaded, but in production, only the css classes used by files in `app/views` and `app/helpers` are included.

This gem just gives access to the standard Tailwind CSS framework. If you need to customize Tailwind, you will need to install it the traditional way using [Webpacker](https://github.com/rails/webpacker) instead. This gem is purely intended for those who wish to use Tailwind CSS with the asset pipeline.

The version of Tailwind included in this gem has been configured for dark mode, forms, aspect-ratio, typography, and the Inter font.


## Installation

1. Run `./bin/bundle add tailwindcss-rails`
2. Run `./bin/rails tailwindcss:install` (on a fresh Rails application)

The last option adds the purger compressor to `config/environments/production.rb`. This ensures that when `assets:precompile` is called during deployment that the unused class names are not included in the tailwind output css used by the app. It also adds a `stylesheet_link_tag "tailwind"` and `stylesheet_link_tag "inter-font"` to your `app/views/application.html.erb` file.

You can do these things yourself, if you've changed the default setup.


## Purging in production

The Tailwind CSS framework starts out as a massive file, which gives you all the combinations of utility classes for development, but you wouldn't want to ship all those unused classes in production. So this gem includes a Sprockets compressor that purges the tailwind file from all those unused classes.

This happens automatically on `assets:precompile`, which should always be part of a deployment path, but is not currently compatible with the default sprockets cache. So you must run the `assets:clobber` task prior to `assets:precompile` when deploying to production, or new new usage of additional utility classes from your view and helper files will not be updated. 


## Configuration

If you need to customize what files are searched for class names, you need to replace the compressor line with something like:

```ruby
  config.assets.css_compressor = Tailwindcss::Compressor.new(files_with_class_names: Rails.root.glob("app/somehere/**/*.*"))
```

By default, the CSS purger will only operate on the tailwind css file included with this gem. If you want to use it more broadly:

```ruby
  config.assets.css_compressor = Tailwindcss::Compressor.new(only_purge: %w[ tailwind and_my_other_css_file ])
```


## License

Tailwind for Rails is released under the [MIT License](https://opensource.org/licenses/MIT).
