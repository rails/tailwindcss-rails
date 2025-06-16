# Tailwind CSS for Rails

[Tailwind CSS](https://tailwindcss.com) is a utility-first CSS framework packed with classes like flex, pt-4, text-center and rotate-90 that can be composed to build any design, directly in your markup.

<!-- regenerate TOC with `rake format:toc` -->

<!-- toc -->

- [Installation](#installation)
  * [Choosing a specific version of `tailwindcss`](#choosing-a-specific-version-of-tailwindcss)
  * [Using a local installation of `tailwindcss`](#using-a-local-installation-of-tailwindcss)
- [Upgrading your application from Tailwind v3 to v4](#upgrading-your-application-from-tailwind-v3-to-v4)
  * [You don't _have_ to upgrade](#you-dont-_have_-to-upgrade)
  * [Upgrade steps](#upgrade-steps)
  * [Troubleshooting a v4 upgrade](#troubleshooting-a-v4-upgrade)
  * [Updating CSS class names for v4](#updating-css-class-names-for-v4)
- [Developing with Tailwindcss](#developing-with-tailwindcss)
  * [Configuration and commands](#configuration-and-commands)
  * [Building for production](#building-for-production)
  * [Building for testing](#building-for-testing)
  * [Building unminified assets](#building-unminified-assets)
  * [Live rebuild](#live-rebuild)
  * [Using Tailwind plugins](#using-tailwind-plugins)
  * [Using with PostCSS](#using-with-postcss)
  * [Custom inputs or outputs](#custom-inputs-or-outputs)
  * [Rails Engines support (Experimental)](#rails-engines-support-experimental)
- [Troubleshooting](#troubleshooting)
  * [The `watch` command is hanging](#the-watch-command-is-hanging)
  * [Lost keystrokes or hanging when using terminal-based debugging tools (e.g. IRB, Pry, `ruby/debug`...etc.) with the Puma plugin](#lost-keystrokes-or-hanging-when-using-terminal-based-debugging-tools-eg-irb-pry-rubydebugetc-with-the-puma-plugin)
  * [Running in a docker container exits prematurely](#running-in-a-docker-container-exits-prematurely)
  * [Conflict with sassc-rails](#conflict-with-sassc-rails)
  * [Class names must be spelled out](#class-names-must-be-spelled-out)
  * [`ERROR: Cannot find the tailwindcss executable` for supported platform](#error-cannot-find-the-tailwindcss-executable-for-supported-platform)
  * [Using asset-pipeline assets](#using-asset-pipeline-assets)
- [License](#license)

<!-- tocstop -->

## Installation

With Rails 7 you can generate a new application preconfigured with Tailwind CSS by using `--css tailwind`. If you're adding Tailwind later, you need to:

1. Run `./bin/bundle add tailwindcss-rails`
2. Run `./bin/rails tailwindcss:install`

This gem depends on the `tailwindcss-ruby` gem to install a working Tailwind CLI executable.

### Choosing a specific version of `tailwindcss`

The `tailwindcss-ruby` gem is declared as a floating dependency of this gem, so by default you will get the most recent stable version. However, you can select a specific version of Tailwind CSS by pinning that gem to the analogous version in your application's `Gemfile`. For example,

```ruby
gem "tailwindcss-rails"

# pin to tailwindcss version 3.4.13
gem "tailwindcss-ruby", "3.4.13"
```

### Using a local installation of `tailwindcss`

You can also use a local (npm-based) installation if you prefer, please go to https://github.com/flavorjones/tailwindcss-ruby for more information.

## Upgrading your application from Tailwind v3 to v4

v4.x of this gem has been updated to work with Tailwind v4, including providing some help with upgrading your application.

A full explanation of a Tailwind CSS v4 upgrade is out of scope for this README, so we **strongly urge** you to read the [official Tailwind CSS v4 upgrade guide](https://tailwindcss.com/docs/upgrade-guide) before embarking on an upgrade to an existing large app.

This gem will help with some of the mechanics of the upgrade:

- update some generated files to handle breaking changes in v4 of this gem,
- update some local project files to meet some Tailwind CSS v4 conventions,
- attempt to run the [upstream v4 upgrade tool](https://tailwindcss.com/docs/upgrade-guide#using-the-upgrade-tool).

### You don't _have_ to upgrade

Keep in mind that you don't _need_ to upgrade. You can stay on Tailwind CSS v3 for the foreseeable future if you prefer not to migrate now, or if your migration runs into problems.

If you don't want to upgrade, then pin your application to v3.3.1 of this gem:

```ruby
# Gemfile
gem "tailwindcss-rails", "~> 3.3.1" # which transitively pins tailwindcss-ruby to v3
```

If you're on an earlier version of this gem, `<= 3.3.0`, then make sure you're pinning the version of **both** `tailwindcss-rails` and `tailwindcss-ruby`:

```ruby
# Gemfile
gem "tailwindcss-rails", "~> 3.3"
gem "tailwindcss-ruby", "~> 3.4" # only necessary with tailwindcss-rails <= 3.3.0
```

### Upgrade steps

> [!WARNING]
> In applications using Tailwind plugins without JavaScript tooling, these upgrade steps may fail to fully migrate `tailwind.config.js` because the upstream upgrade tool needs the Tailwind plugins to be installed and available through a JavaScript package manager. If you see errors from the upstream upgrade tool, you should try following the additional steps in [Updating CSS class names for v4](#updating-css-class-names-for-v4) which will help you install (temporarily!) the necessary packages and clean up afterwards.

First, update to `tailwindcss-rails` v4.0.0 or higher. This will also ensure you're transitively depending on `tailwindcss-ruby` v4.

```ruby
# Gemfile 
gem "tailwindcss-rails", "~> 4.0" # which transitively pins tailwindcss-ruby to v4
```

**Update** path references to any existing css files imported in `app/assets/stylesheets/application.tailwind.css` so that they will resolve when the file is moved to `app/assets/tailwind/application.css`.

```diff
-@import "pagy.css";
+@import "../stylesheets/pagy.css";
```

If you want to migrate CSS class names for v4 (this is an optional step!), jump to [Updating CSS class names for v4](#updating-css-class-names-for-v4) before continuing.

Then, run `bin/rails tailwindcss:upgrade`. Among other things, this will try to run the official Tailwind upgrade utility. It requires `npx` in order to run, but it's a one-time operation and is _highly recommended_ for a successful upgrade.

<details>
<summary>Here's a detailed list of what the upgrade task does.</summary>

- Cleans up some things in the generated `config/tailwind.config.js`.
- If present, moves `config/postcss.config.js` to the root directory.
- If present, moves `app/assets/stylesheets/application.tailwind.css` to `app/assets/tailwind/application.css`.
- Removes unnecessary `stylesheet_link_tag "tailwindcss"` tags from the application layout.
- Removes references to the Inter font from the application layout.
- Runs v4.1.4 of the upstream upgrader (note: requires `npx` to run the one-time upgrade, but highly recommended).

</details>

<details>
<summary>Here's what that upgrade looks like on a vanilla Rails app.</summary>

```sh
$ bin/rails tailwindcss:upgrade
       apply  /path/to/tailwindcss-rails/lib/install/upgrade_tailwindcss.rb
  Removing references to 'defaultTheme' from /home/user/myapp/config/tailwind.config.js
        gsub    config/tailwind.config.js
  Strip Inter font CSS from application layout
        gsub    app/views/layouts/application.html.erb
  Remove unnecessary stylesheet_link_tag from application layout
        gsub    app/views/layouts/application.html.erb
  Moving /home/user/myapp/app/assets/stylesheets/application.tailwind.css to /home/user/myapp/app/assets/tailwind/application.css
      create    app/assets/tailwind/application.css
      remove    app/assets/stylesheets/application.tailwind.css
10.9.0
  Running the upstream Tailwind CSS upgrader
         run    npx @tailwindcss/upgrade@4.1.4 --force --config /home/user/myapp/config/tailwind.config.js from "."
≈ tailwindcss v4.0.0
│ Searching for CSS files in the current directory and its subdirectories…
│ ↳ Linked `./config/tailwind.config.js` to `./app/assets/tailwind/application.css`
│ Migrating JavaScript configuration files…
│ ↳ The configuration file at `./config/tailwind.config.js` could not be automatically migrated to the new CSS
│   configuration format, so your CSS has been updated to load your existing configuration file.
│ Migrating templates…
│ ↳ Migrated templates for configuration file: `./config/tailwind.config.js`
│ Migrating stylesheets…
│ ↳ Migrated stylesheet: `./app/assets/tailwind/application.css`
│ ↳ No PostCSS config found, skipping migration.
│ Updating dependencies…
│ Could not detect a package manager. Please manually update `tailwindcss` to v4.
│ Verify the changes and commit them to your repository.
  Compile initial Tailwind build
         run    rails tailwindcss:build from "."
≈ tailwindcss v4.0.0
Done in 56ms
         run  bundle install --quiet
```

</details>

If this doesn't succeed, it's likely that you've customized your Tailwind configuration and you'll need to do some work to make sure your application upgrades. Please read the [official upgrade guide](https://tailwindcss.com/docs/upgrade-guide) and try following the additional steps in [Updating CSS class names for v4](#updating-css-class-names-for-v4).

### Troubleshooting a v4 upgrade

You may want to check out [TailwindCSS v4 - upgrade experience report · rails/tailwindcss-rails · Discussion #450](https://github.com/rails/tailwindcss-rails/discussions/450) if you're having trouble upgrading.

We know there are some cases we haven't addressed with the upgrade task:

- In applications using Tailwind plugins without JavaScript tooling, these upgrade steps may fail to fully migrate `tailwind.config.js` because the upstream upgrade tool needs the Tailwind plugins to be installed and available through a JavaScript package manager. If you see errors from the upstream upgrade tool, you should try following the additional steps in [Updating CSS class names for v4](#updating-css-class-names-for-v4) which will help you install (temporarily!) the necessary packages and clean up afterwards.

We'll try to improve the upgrade process over time, but for now you may need to do some manual work to upgrade.

### Updating CSS class names for v4

> [!NOTE]
> If you'd like to help automate these steps, please drop a note to the maintainers in [this discussion thread](https://github.com/rails/tailwindcss-rails/discussions/450).

With some additional manual work the upstream upgrade tool will update your application's CSS class names to v4 conventions. **This is an optional step that requires a JavaScript toolchain.**

**Add** the following line to the `.gitignore` file, to prevent the upstream upgrade tool from accessing node_modules files.

```gitignore
/node_modules
```

**Create** or **update** a `package.json` in the root of the project:

```jsonc
{
  "name": "app_name",
  "version": "1.0.0",
  "dependencies": {
    "tailwindcss": "^3.4.17", // Mandatory!!
    // Install all plugins and modules that are referenced in tailwind.config.js
    "@tailwindcss/aspect-ratio": "^0.4.2",
    "@tailwindcss/container-queries": "^0.1.1",
    "@tailwindcss/forms": "^0.5.10",
    "@tailwindcss/typography": "^0.5.16",
    // And so on...
  },
}
```

**Run** `npm install` (or `yarn install` if using `yarn`)

**Update** `config/tailwind.config.js` and temporarily change the `content` part to have an additional `.` on all paths so they are relative to the config file:

```js
  content: [
    '../public/*.html',
    '../app/helpers/**/*.rb',
    '../app/javascript/**/*.js',
    '../app/views/**/*.{erb,haml,html,slim}'
  ],
```

(Just add an additional `.` to all the paths referenced)

**Run** the upstream upgrader as instructed above.

Then, once you've run that successfully, clean up:

- **Review** `package.json` to remove unnecessary modules.
  - This includes modules added for the period of upgrade.
  - If you don't need any modules besides `tailwindcss` itself, **delete** `package.json`, `node_modules/` and `package-lock.json` (or `yarn.lock`), plus remove `/node_modules` from `.gitignore`.
- **Go** to your CSS file and remove the following line (if present):
  ```css
  @plugin '@tailwindcss/container-queries';
  ```
- **Revert** the changes to `config/tailwind.config.js` so that paths are once again relative to the application root.

## Developing with Tailwindcss

### Configuration and commands

#### Input file: `app/assets/tailwind/application.css`

The `tailwindcss:install` task will generate a Tailwind input file in `app/assets/tailwind/application.css`. This is where you import the plugins you want to use and where you can setup your custom `@apply` rules.

⚠ The location of this file changed in v4, from `app/assets/stylesheets/application.tailwind.css` to `app/assets/tailwind/application.css`. The `tailwindcss:upgrade` task will move it for you.

#### Output file: `app/assets/builds/tailwind.css`

When you run `rails tailwindcss:build`, the input file will be used to generate the output in `app/assets/builds/tailwind.css`. That's the output CSS that you'll include in your app.

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

If you want unminified assets, you can:

- pass a `debug` argument to the rake task, i.e. `rails tailwindcss:build[debug]` or `rails tailwindcss:watch[debug]`.
- set an environment variable named `TAILWINDCSS_DEBUG` with a non-blank value

If both values are set, the environment variable will take precedence over the rake task argument.

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

### Using Tailwind plugins

If you want to use Tailwind plugins, they can be installed using `package.json`.

Using Yarn:

```sh
[ ! -f package.json ] && yarn init
yarn add daisyui # example
```

Using npm:

```sh
npm init
npm add daisyui # example
```

Than use `@plugin` annotation in `app/assets/tailwind/application.css`:

```css
@import "tailwindcss";
@plugin "daisyui";
```

### Using with PostCSS

If you want to use PostCSS as a preprocessor, create a custom `postcss.config.js` in your project root directory, and that file will be loaded by Tailwind automatically.

For example, to enable nesting:

```js
// postcss.config.js
export default {
  plugins: {
    "@tailwindcss/postcss": {},
  },
};
```

⚠ Note that PostCSS is a JavaScript tool with its own prerequisites! By default `tailwindcss-rails` does not require any JavaScript tooling, so in order to use PostCSS, a `package.json` with dependencies for your plugins and a package manager like `yarn` or `npm` is required, for example:

```json
// package.json
{
  "name": "my app",
  "private": true,
  "dependencies": {
    "@tailwindcss/postcss": "^4.0.0",
    "tailwindcss": "^4.0.0",
    "postcss": "^8.5.1"
  }
}
```

Then you can use yarn or npm to install the dependencies.

### Custom inputs or outputs

If you need to use a custom input or output file, you can run `bundle exec tailwindcss` to access the platform-specific executable, and give it your own build options.

### Rails Engines support (Experimental)

_This feature is experimental and may change in the future. If you have feedback, please join the [discussion](https://github.com/rails/tailwindcss-rails/discussions/355)._

If you have Rails Engines in your application that use Tailwind CSS and provide an `app/assets/tailwind/<engine_name>/engine.css` file, entry point files will be created for each of them in `app/assets/builds/tailwind/<engine_name>.css` on the first build/watch invocation or manual call for `rails tailwindcss:engines` so they can be included in your host application's Tailwind CSS by adding `@import "../builds/tailwind/<engine_name>"` to your `app/assets/tailwind/application.css` file.

> [!IMPORTANT]
> You must `@import` the engine CSS files in your `app/assets/tailwind/application.css` for the engine to be included in the build. By default, no engine CSS files are imported, and you must opt-in to using the file in your build.

## Troubleshooting

When having trouble with `tailwindcss:build` or `tailwindcss:watch`, the first thing you should do is collect some diagnostic information by setting the "verbose" flag, which will emit:

1. the command being run (so you can try running `tailwindcss` yourself without the gem's help)
2. additional debugging output from `tailwindcss` by setting the env var `DEBUG=1`

Here's what that looks like:

```sh
$ bin/rails tailwindcss:build[verbose]

Running: /path/to/tailwindcss-ruby-4.0.17-x86_64-linux-gnu/exe/x86_64-linux-gnu/tailwindcss -i /home/flavorjones/code/oss/tailwindcss-rails/My Workspace/test-install/app/assets/tailwind/application.css -o /home/flavorjones/code/oss/tailwindcss-rails/My Workspace/test-install/app/assets/builds/tailwind.css --minify
≈ tailwindcss v4.0.17

Done in 37ms

[38.22ms] [@tailwindcss/cli] (initial build)
[11.90ms]   ↳ Setup compiler
[ 6.52ms]   ↳ Scan for candidates
[10.39ms]   ↳ Build CSS
[ 1.69ms]   ↳ Optimize CSS
[ 5.80ms]   ↳ Write output
```

### The `watch` command is hanging

There is a [known issue](https://github.com/tailwindlabs/tailwindcss/issues/17246#issuecomment-2753067488) running `tailwindcss -w` (that's the CLI in watch mode) when the utility `watchman` is also installed.

Please try uninstalling `watchman` and try running the watch task again.

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

In Rails, you want to use [assets from the asset pipeline to get fingerprinting](https://guides.rubyonrails.org/asset_pipeline.html#fingerprinting-versioning-with-digest-based-urls). However, Tailwind isn't aware of those assets.

To use assets from the pipeline, use `url(image.svg)`. [Since Sprockets v3.3.0](https://github.com/rails/sprockets-rails/pull/476) `url(image.svg)` is rewritten to `/path/to/assets/image-7801e7538c6f1cc57aa75a5876ab0cac.svg` so output CSS will have the correct path to those assets.

```js
module.exports = {
  theme: {
    extend: {
      backgroundImage: {
        image: "url('image.svg')",
      },
    },
  },
};
```

The inline version also works:

```html
<section class="bg-[url('image.svg')]">
  Has the image as it's background
</section>
```

## License

Tailwind for Rails is released under the [MIT License](https://opensource.org/licenses/MIT).
