# Tailwind CSS for Rails

[Tailwind CSS](https://tailwindcss.com) is a utility-first CSS framework packed with classes like flex, pt-4, text-center and rotate-90 that can be composed to build any design, directly in your markup.

<!-- regenerate TOC with `rake format:toc` -->

<!-- toc -->

- [Installation](#installation)
  * [Choosing a specific version of `tailwindcss`](#choosing-a-specific-version-of-tailwindcss)
  * [Using a local installation of `tailwindcss`](#using-a-local-installation-of-tailwindcss)
- [Developing with Tailwindcss](#developing-with-tailwindcss)
  * [Configuration and commands](#configuration-and-commands)
  * [Building for production](#building-for-production)
  * [Building for testing](#building-for-testing)
  * [Building unminified assets](#building-unminified-assets)
  * [Live rebuild](#live-rebuild)
  * [Using with PostCSS](#using-with-postcss)
  * [Custom inputs or outputs](#custom-inputs-or-outputs)
- [Troubleshooting](#troubleshooting)
  * [Lost keystrokes or hanging when using terminal-based debugging tools (e.g. IRB, Pry, `ruby/debug`...etc.) with the Puma plugin](#lost-keystrokes-or-hanging-when-using-terminal-based-debugging-tools-eg-irb-pry-rubydebugetc-with-the-puma-plugin)
  * [Running in a docker container exits prematurely](#running-in-a-docker-container-exits-prematurely)
  * [Conflict with sassc-rails](#conflict-with-sassc-rails)
  * [Class names must be spelled out](#class-names-must-be-spelled-out)
  * [`ERROR: Cannot find the tailwindcss executable` for supported platform](#error-cannot-find-the-tailwindcss-executable-for-supported-platform)
  * [Using asset-pipeline assets](#using-asset-pipeline-assets)
  * [Conflict with pre-existing asset pipeline stylesheets](#conflict-with-pre-existing-asset-pipeline-stylesheets)
- [License](#license)

<!-- tocstop -->

## Installation

With Rails 7 you can generate a new application preconfigured with Tailwind by using `--css tailwind`. If you're adding Tailwind later, you need to:

1. Run `./bin/bundle add tailwindcss-rails`
2. Run `./bin/rails tailwindcss:install`

This gem depends on the `tailwindcss-ruby` gem to install a working tailwind executable.


### Choosing a specific version of `tailwindcss`

The `tailwindcss-ruby` gem is declared as a floating dependency of this gem, so by default you will get the most recent stable version. However, you can select a specific version of tailwind by pinning that gem to the analogous version in your application's `Gemfile`. For example,

``` ruby
gem "tailwindcss-rails"

# pin to tailwindcss version 3.4.13
gem "tailwindcss-ruby", "3.4.13"
```

### Using a local installation of `tailwindcss`

You can also use a local (npm-based) installation if you prefer, please go to https://github.com/flavorjones/tailwindcss-ruby for more information.


## Developing with Tailwindcss

### Configuration and commands

#### Configuration file: `config/tailwind.config.js`

You can customize the Tailwind build through the `config/tailwind.config.js` file, just like you would if Tailwind was running in a traditional node installation. All the first-party plugins are supported.

#### Input file: `app/assets/stylesheets/application.tailwind.css`

The installer will generate a Tailwind input file in `app/assets/stylesheets/application.tailwind.css`. This is where you import the plugins you want to use, and where you can setup your custom `@apply` rules.

#### Output file: `app/assets/builds/tailwind.css`

When you run `rails tailwindcss:build`, the input file will be used to generate the output in `app/assets/builds/tailwind.css`. That's the output CSS that you'll include in your app (the installer automatically configures this, alongside the Inter font as well).

#### Commands

This gem makes several Rails tasks available, some of which have multiple options which can be combined.

Synopsis:

- `bin/rails tailwindcss:install` - installs the configuration file, output file, and `Procfile.dev`
- `bin/rails tailwindcss:build` - generate the output file
  - `bin/rails tailwindcss:build[debug]` - generate unminimized output
- `bin/rails tailwindcss:watch` - start live rebuilds, generating output on file changes
  - `bin/rails tailwindcss:watch[debug]` - generate unminimized output
  - `bin/rails tailwindcss:watch[poll]` - for systems without file system events
  - `bin/rails tailwindcss:watch[always]` - for systems without TTY (e.g., some docker containers)

Note that you can combine task options, e.g. `rails tailwindcss:watch[debug,poll]`.

This gem also makes available a Puma plugin to manage a live rebuild process when you run `rails server` (see "Live Rebuild" section below).

This gem also generates a `Procfile.dev` file which will run both the rails server and a live rebuild process (see "Live Rebuild" section below).


### Building for production

The `tailwindcss:build` is automatically attached to `assets:precompile`, so before the asset pipeline digests the files, the Tailwind output will be generated.


### Building for testing

The `tailwindcss:build` task is automatically attached to the `test:prepare` Rake task. This task runs before test commands. If you run `bin/rails test` in your CI environment, your Tailwind output will be generated before tests run.


### Building unminified assets

If you want unminified assets, you can pass a `debug` argument to the rake task, i.e. `rails tailwindcss:build[debug]` or `rails tailwindcss:watch[debug]`.


### Live rebuild

While you're developing your application, you want to run Tailwind in "watch" mode, so changes are automatically reflected in the generated CSS output. You can do this in a few different ways:

- use this gem's [Puma](https://puma.io/) plugin to integrate "watch" with `rails server`,
- or run `rails tailwindcss:watch` as a separate process,
- or run `bin/dev` which uses [Foreman](https://github.com/ddollar/foreman)


#### Puma plugin

This gem ships with a Puma plugin. To use it, add this line to your `puma.rb` configuration:

```ruby
plugin :tailwindcss if ENV.fetch("RAILS_ENV", "development") == "development"
```

and then running `rails server` (or just `puma`) will run the Tailwind watch process in the background.


#### Run `rails tailwindcss:watch`

This is a flexible command, which can be run with a few different options.

If you are running `rails tailwindcss:watch` on a system that doesn't fully support file system events, pass a `poll` argument to the task to instruct tailwindcss to instead use polling:

```
rails tailwindcss:watch[poll]
```

(If you use `bin/dev` then you should modify your `Procfile.dev` to use the `poll` option.)

If you are running `rails tailwindcss:watch` as a process in a Docker container, set `tty: true` in `docker-compose.yml` for the appropriate container to keep the watch process running.

If you are running `rails tailwindcss:watch` in a docker container without a tty, pass the `always` argument to the task to instruct tailwindcss to keep the watcher alive even when `stdin` is closed: `rails tailwindcss:watch[always]`. If you use `bin/dev` then you should modify your `Procfile.dev`.


#### Foreman

Running `bin/dev` invokes Foreman to start both the Tailwind watch process and the rails server in development mode based on your `Procfile.dev` file.


### Using with PostCSS

If you want to use PostCSS as a preprocessor, create a custom `config/postcss.config.js` and that file will be loaded by tailwind automatically.

For example, to enable nesting:

```js
// config/postcss.config.js
module.exports = {
  plugins: {
    'postcss-import': {},
    'tailwindcss/nesting': {},
    tailwindcss: {},
    autoprefixer: {},
  },
}
```

⚠ Note that PostCSS is a javascript tool with its own prerequisites! By default `tailwindcss-rails` does not require any javascript tooling, so in order to use PostCSS, a `package.json` with dependencies for your plugins and a package manager like `yarn` or `npm` is required, for example:

```json
// package.json
{
  "name": "my app",
  "private": true,
  "dependencies": {
    "postcss-advanced-variables": "^4.0.0",
    "postcss-import": "^16.0.1",
    "postcss-mixins": "^9.0.4",
    "tailwindcss": "^3.4.1"
  }
}
```

Then you can use yarn or npm to install the dependencies.


### Custom inputs or outputs

If you need to use a custom input or output file, you can run `bundle exec tailwindcss` to access the platform-specific executable, and give it your own build options.


## Troubleshooting

Some common problems experienced by users ...

### Lost keystrokes or hanging when using terminal-based debugging tools (e.g. IRB, Pry, `ruby/debug`...etc.) with the Puma plugin

We've addressed the issue and you can avoid the problem by upgrading `tailwindcss-rails` to [v2.4.1](https://github.com/rails/tailwindcss-rails/releases/tag/v2.4.1) or later versions.

### Running in a docker container exits prematurely

If you are running `rails tailwindcss:watch` as a process in a Docker container, set `tty: true` in `docker-compose.yml` for the appropriate container to keep the watch process running.

If you are running `rails tailwindcss:watch` in a docker container without a tty, pass the `always` argument to the task to instruct tailwindcss to keep the watcher alive even when `stdin` is closed: `rails tailwindcss:watch[always]`. If you use `bin/dev` then you should modify your `Procfile.dev`.

### Conflict with sassc-rails

Tailwind uses modern CSS features that are not recognized by the `sassc-rails` extension that was included by default in the Gemfile for Rails 6. In order to avoid any errors like `SassC::SyntaxError`, you must remove that gem from your Gemfile.

### Class names must be spelled out

For Tailwind to work, your class names need to be spelled out. If you need to make sure Tailwind generates class names that don't exist in your content files or that are programmatically composed, use the [safelist option](https://tailwindcss.com/docs/content-configuration#safelisting-classes).

### `ERROR: Cannot find the tailwindcss executable` for supported platform

See https://github.com/flavorjones/tailwindcss-ruby for help.

### Using asset-pipeline assets

In Rails, you want to use [assets from the asset pipeline to get fingerprinting](https://guides.rubyonrails.org/asset_pipeline.html#what-is-fingerprinting-and-why-should-i-care-questionmark). However, Tailwind isn't aware of those assets.

To use assets from the pipeline, use `url(image.svg)`. [Since Sprockets v3.3.0](https://github.com/rails/sprockets-rails/pull/476) `url(image.svg)` is rewritten to `/path/to/assets/image-7801e7538c6f1cc57aa75a5876ab0cac.svg` so output CSS will have the correct path to those assets.

```js
module.exports = {
    theme: {
        extend: {
            backgroundImage: {
                'image': "url('image.svg')"
            }
        }
    }
}
```

The inline version also works:

```html
<section class="bg-[url('image.svg')]">Has the image as it's background</section>
```

### Conflict with pre-existing asset pipeline stylesheets

If you get a warning `Unrecognized at-rule or error parsing at-rule ‘@tailwind’.` in the browser console after installation, you are incorrectly double-processing `application.tailwind.css`. This is a misconfiguration, even though the styles will be fully effective in many cases.

The file `application.tailwind.css` is installed when running `rails tailwindcss:install` and is placed alongside the common `application.css` in `app/assets/stylesheets`. Because the `application.css` in a newly generated Rails app includes a `require_tree .` directive, the asset pipeline incorrectly processes `application.tailwind.css`, where it should be taken care of by `tailwindcss`. The asset pipeline ignores TailwindCSS's at-directives, and the browser can't process them.

To fix the warning, you can either remove the `application.css`, if you don't plan to use the asset pipeline for stylesheets, and instead rely on TailwindCSS completely for styles. This is what this installer assumes.

Or, if you do want to keep using the asset pipeline in parallel, make sure to remove the `require_tree .` line from the `application.css`.


## License

Tailwind for Rails is released under the [MIT License](https://opensource.org/licenses/MIT).
The Inter font is released under the [SIL Open Font License, Version 1.1](https://github.com/rsms/inter/blob/master/LICENSE.txt).
