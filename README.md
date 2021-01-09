# Tailwind CSS for Rails

[Tailwindcss](https://tailwindcss.hotwire.dev) is a JavaScript framework with modest ambitions. It doesn’t seek to take over your entire front-end in fact, it’s not concerned with rendering HTML at all. Instead, it’s designed to augment your HTML with just enough behavior to make it shine. Tailwindcss pairs beautifully with Turbo to provide a complete solution for fast, compelling applications with a minimal amount of effort.

Tailwindcss for Rails makes it easy to use this modest framework with the asset pipeline and ES6/ESM in the browser. It uses the 7kb es-module-shim to provide [importmap](https://github.com/WICG/import-maps) support for all ES6-compatible browsers. This means you can develop and deploy without using any bundling or transpiling at all! Far less complexity, no waiting for compiling.

If you want to use Tailwindcss with a bundler, you should use [Webpacker](https://github.com/rails/webpacker) instead. This gem is purely intended for those who wish to use Tailwindcss with the asset pipeline using ESM in the browser.

## Installation

1. Add the `tailwind-rails` gem to your Gemfile: `gem 'tailwind-rails'`
2. Run `./bin/bundle install`.
3. Run `./bin/rails tailwind:install`


## Usage




## License

Tailwind for Rails is released under the [MIT License](https://opensource.org/licenses/MIT).
