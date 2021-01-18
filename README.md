# Tailwind CSS for Rails

[Tailwind CSS](https://tailwindcss.com) is a utility-first CSS framework packed with classes like flex, pt-4, text-center and rotate-90 that can be composed to build any design, directly in your markup.

Tailwind CSS for Rails makes it easy to use this CSS framework with the asset pipeline. In development mode, the full 3mb+ Tailwind stylsheet is loaded, but in production, only the css classes used by files in `app/views` and `app/helpers` are included.

This gem just gives access to the standard Tailwind CSS framework. If you need to customize Tailwind, you will need to install it the traditional way using [Webpacker](https://github.com/rails/webpacker) instead. This gem is purely intended for those who wish to use Tailwind CSS with the asset pipeline.


## Installation

1. Run `./bin/bundle add tailwindcss-rails`
2. Run `./bin/rails tailwindcss:install` (on a fresh Rails application)

The last option adds the purger compressor to `config/environments/production.rb`. This ensures that when `assets:precompile` is called during deployment that the unused class names are not included in the tailwind output css used by the app. It also adds a `stylesheet_link_tag "tailwind"` to your `app/views/application.html.erb` file.

However, re-compiling assets does not currently work as expected because of caching in Sprockets, so you'll need to call `assets:clobber` and `assets:precompile` on each deployment for now. 

You can do both things yourself, if you've changed the default setup.

If you need to customize what files are searched for class names, you need to replace the compressor line with something like:

```ruby
  config.assets.css_compressor = Tailwindcss::Compressor.new(files_with_class_names: Rails.root.glob("app/somehere/**/*.*"))
```


## License

Tailwind for Rails is released under the [MIT License](https://opensource.org/licenses/MIT).
