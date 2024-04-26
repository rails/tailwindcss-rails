# Tailwind CSS for Rails

[Tailwind CSS](https://tailwindcss.com) is a utility-first CSS framework packed with classes like flex, pt-4, text-center and rotate-90 that can be composed to build any design, directly in your markup.

<!-- regenerate TOC with `rake format:toc` -->

<!-- toc -->

- [Installation](#installation)
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
  * [Lost keystrokes or hanging when using `ruby/debug` with the Puma plugin](#lost-keystrokes-or-hanging-when-using-rubydebug-with-the-puma-plugin)
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

This gem wraps [the standalone executable version](https://tailwindcss.com/blog/standalone-cli) of the Tailwind CSS v3 framework. These executables are platform specific, so there are actually separate underlying gems per platform, but the correct gem will automatically be picked for your platform.

Supported platforms are:

- arm64-darwin (macos-arm64)
- x64-mingw32 (windows-x64)
- x64-mingw-ucr (windows-x64)
- x86_64-darwin (macos-x64)
- x86_64-linux (linux-x64)
- aarch64-linux (linux-arm64)
- arm-linux (linux-armv7)


### Using a local installation of `tailwindcss`

If you are not able to use the vendored standalone executables (for example, if you're on an unsupported platform), you can use a local installation of the `tailwindcss` executable by setting an environment variable named `TAILWINDCSS_INSTALL_DIR` to the directory path containing the executable.

For example, if you've installed `tailwindcss` so that the executable is found at `/path/to/node_modules/bin/tailwindcss`, then you should set your environment variable like so:

``` sh
TAILWINDCSS_INSTALL_DIR=/path/to/node_modules/bin
```

or, for relative paths like `./node_modules/.bin/tailwindcss`:

``` sh
TAILWINDCSS_INSTALL_DIR=node_modules/.bin
```


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

and then running `rails server` will run the Tailwind watch process in the background


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

If you want to use PostCSS as a preprocessor, create a custom `config/postcss.config.js` and it will be loaded automatically.

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

Some users are reporting this error even when running on one of the supported native platforms:

- arm64-darwin
- x64-mingw32
- x64-mingw-ucrt
- x86_64-darwin
- x86_64-linux
- aarch64-linux

#### Check Bundler PLATFORMS

A possible cause of this is that Bundler has not been told to include native gems for your current platform. Please check your `Gemfile.lock` file to see whether your native platform is included in the `PLATFORMS` section. If necessary, run:

``` sh
bundle lock --add-platform <platform-name>
```

and re-bundle.


#### Check BUNDLE_FORCE_RUBY_PLATFORM

Another common cause of this is that bundler is configured to always use the "ruby" platform via the
`BUNDLE_FORCE_RUBY_PLATFORM` config parameter being set to `true`. Please remove this configuration:

``` sh
bundle config unset force_ruby_platform
# or
bundle config set --local force_ruby_platform false
```

and re-bundle.

See https://bundler.io/man/bundle-config.1.html for more information.


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
Tailwind CSS is released under the [MIT License](https://opensource.org/licenses/MIT).
The Inter font is released under the [SIL Open Font License, Version 1.1](https://github.com/rsms/inter/blob/master/LICENSE.txt).
