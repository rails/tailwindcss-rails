# `tailwindcss-rails` Changelog

## v4.2.2 / 2025-04-05

### Improved

* The "tailwindcss:upgrade" task now uses the latest version of the `@tailwindcss/upgrade` tool. #529 @flavorjones
* The "verbose" flag on Rails tasks now emits additional tailwind CLI debugging info (e.g., `bin/rails tailwindcss:build[verbose]`). #530 @flavorjones
* Simplified the scaffold templates, removing unnecessary `div` tags. @523 @patriciomacadden


## v4.2.1 / 2025-03-19

### Fixed

* Fix styles for form errors in some scaffold fields. #513 @patriciomacadden
* Update scaffold system tests to handle the "Destroy" confirmation prompt when Turbo is enabled. Fixes #519. #520 @patriciomacadden @flavorjones


## v4.2.0 / 2025-03-02

### Features

* Improve the view templates to display better on mobile devices. #503 @patriciomacadden
* Support for environment variable `TAILWINDCSS_DEBUG` to turn off CSS minification. #504 @r-sierra


## v4.1.0 / 2025-02-19

### View template improvements

* Field outlines are no longer hidden, and the focus border is brighter. #489 @rubys
* Boolean fields are improved (checkbox labels aligned, "Yes"/"No" instead of "true"/"false"). #454 @patriciomacadden
* Attachment links are consistently spaced and styled. #460 @patriciomacadden
* Index page links to Show, Edit, and Destroy for each resource. #460 @patriciomacadden @flavorjones
* Turbo confirm prompt added to Destroy links. #498 @patriciomacadden


## v4.0.0 / 2025-02-01

### Upgrade to Tailwind CSS v4

General changes:

- The dependency on `tailwindcss-ruby` is set to `~> 4.0`.
- The location of (optional) `postcss.config.js` has moved from the `config/` directory to the app root.
- The input file `app/assets/tailwind/application.tailwind.css` has been renamed to `app/assets/tailwind/application.css`.
- If Propshaft is being used, `app/assets/tailwind` will be excluded from its asset handling.
- The Inter font is no longer packaged with the gem.
- Some Tailwind class names in the generated ERB templates are updated for v4.
- The README is updated to contain verbose instructions on upgrading.

Changes to the `tailwindcss:install` task:

- The `tailwindcss:install` task no longer installs `config/tailwind.config.js`, as v4 recommends placing Tailwind configuration in the CSS file.
- The Inter font is no longer configured in the application layout.
- The "tailwind" stylesheet link tag will only be added to the application layout if Propshaft isn't in use and therefore already handling `app/assets/build/tailwind.css`. Previously it was always injected, resulting in the tag being rendered twice if Propshaft was in use.

New task `tailwindcss:upgrade` upgrades many apps cleanly:

- Cleans up `config/tailwind.config.js` and references it from the CSS file as recommended for v4 upgrades.
- Runs the upstream upgrader (note: requires `npx` to run the one-time upgrade, but highly recommended).
- Removes configuration for the Inter font from the application layout.
- If present, moves `config/postcss.config.js` to the root directory.
- The "tailwind" stylesheet link tag will be removed if Propshaft is in use and already handling `app/assets/build/tailwind.css`.
- The input file `app/assets/tailwind/application.tailwind.css` will be moved to `app/assets/tailwind/application.css`.

Thanks to @EricGusmao, @patriciomacadden, @excid3, and @brunoprietog for their feedback, contributions, and advice on v4 support.

### Other changes

- The gem's Rails generators are now hidden in the `rails g --help` output. #483 @patriciomacadden

## v3.3.1 / 2025-01-23

* Pin the dependency on `tailwindcss-ruby` to `~> 3.0` to prevent users from upgrading Tailwind while still on v3 of this gem.

  While it was useful during the Tailwind v4 beta period to allow users to float this dependency to try upgrading, we know (now that v4.0.0.rc1 of this gem is out) that not everything will work well if combining Tailwind v4 with `tailwindcss-rails` v3. Pinning this dependency should protect developers against unexpected issues.


## v3.3.0 / 2025-01-19

* Add support for using the puma plugin in a standalone puma process (outside of `rails server`). (#458) @flavorjones


## v3.2.0 / 2025-01-10

* Improve the scaffold views by making positions, padding, and sizes more consistent, add titles to all pages, add hover states and semantic colors to buttons and links, and change border and focus colors on fields with errors. (#452) @patriciomacadden


## v3.1.0 / 2024-12-29

### Notable changes

The tailwindcss plugins "form", "typography", and "container-queries" have been dropped from the default generated `tailwind.config.js` file. If you'd like to use them, you can re-add them to your project by uncommenting the appropriate lines in your config file. (#446) @flavorjones


## v3.0.0 / 2024-10-15

### Notable changes

* The upstream `tailwindcss` executable has been extracted from this gem into a new dependency, `tailwindcss-ruby`. @flavorjones

  In advance of the upcoming TailwindCSS v4 release, we are decoupling the `tailwindcss` executable from the Rails integration. This will allow users to upgrade TailwindCSS at a time of their choosing, and allow early adopters to start using the beta releases.


## v2.7.9 / 2024-10-10

* Fix the scaffold form template to render text forms and check boxes properly in all versions of Rails. (#418) @Earlopain


## v2.7.8 / 2024-10-08

* Fix the scaffold form template to render checkboxes properly. (#416) @enderahmetyurt


## v2.7.7 / 2024-10-02

* Proactively support changes to Rails's authentication templates shipping in Rails 8.0.0.beta2 (which is not yet released). (#407, #408) @seanpdoyle @flavorjones


## v2.7.6 / 2024-09-23

* Update to [Tailwind CSS v3.4.13](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.4.13) @flavorjones


## v2.7.5 / 2024-09-18

* Update to [Tailwind CSS v3.4.12](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.4.12) @flavorjones


## v2.7.4 / 2024-09-13

* Update to [Tailwind CSS v3.4.11](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.4.11) @flavorjones


## v2.7.3 / 2024-08-14

* Update to [Tailwind CSS v3.4.10](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.4.10) @flavorjones


## v2.7.2 / 2024-08-08

* Update to [Tailwind CSS v3.4.9](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.4.9) @flavorjones


## v2.7.1 / 2024-08-07

* Update to [Tailwind CSS v3.4.8](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.4.8) @flavorjones


## v2.7.0 / 2024-08-05

* Add specialized views for the new authentication generator coming in Rails 8. (#384) @yshmarov @dhh @flavorjones


## v2.6.5 / 2024-07-30

* During installation, clobber the Rails v8 default `bin/dev` file without requiring human intervention. (#385) @jeromedalbert


## v2.6.4 / 2024-07-27

* Update to [Tailwind CSS v3.4.7](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.4.7) (#383) @flavorjones


## v2.6.3 / 2024-07-16

* Update to [Tailwind CSS v3.4.6](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.4.6) (#381) @flavorjones


## v2.6.2 / 2024-07-15

* Update to [Tailwind CSS v3.4.5](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.4.5) (#380) @flavorjones


## v2.6.1 / 2024-06-05

* Update to [Tailwind CSS v3.4.4](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.4.4) (#373) @flavorjones


## v2.6.0 / 2024-05-04

* Increase form input field border contrast. (#356) @olivierlacan
* Bring the scaffold templates up to date with rails/rails. (#357, #359) @kinsomicrote
* Drop support for Rails 6.0, which reached end-of-life in June 2023. (#358) @flavorjones
* Drop feature and bug fix support for Rails 6.1. The previous minor release will still receive security support while Rails 6.1 is supported. (#359) @flavorjones


## v2.5.0 / 2024-04-27

* Remove the `@tailwindcss/aspect-ratio` plugin from the `tailwind.config.js` that gets installed by the generator. This plugin was originally a polyfill until Safari 15 was released (in Fall 2021), and so is beyond its useful lifetime for anyone not targetting ancient browsers. (#344) @flavorjones @searls


## v2.4.1 / 2024-04-25

* Fix debugger repl when using the Puma plugin. (#349) @tompng


## v2.4.0 / 2024-04-08

* Update to [Tailwind CSS v3.4.3](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.4.3) from v3.4.1 by @flavorjones
* The `tailwindcss:watch` task handles interrupts more cleanly. (#318, #336) @davidcelis


## v2.3.0 / 2024-01-10

* Allow applications to override the generator templates. (#314) @flavorjones
* Support using PostCSS as a preprocessor. (#316) @ahmeij


## v2.2.1 / 2024-01-07

* Update to [Tailwind CSS v3.4.1](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.4.1) from v3.4.0 by @flavorjones
* Fix `password` form field styling in generated scaffold forms. (#304, #307) @flavorjones
* Fix namespaced mailer generation. (#272, #308) @flavorjones
* Allow overriding the generator templates by placing application templates in either `lib/templates/tailwindcss/{scaffold,mailer,controller}` or `lib/templates/erb/{scaffold,mailer,controller}`. (#164, #314) @flavorjones


## v2.2.0 / 2024-01-04

* Introduce a Puma plugin to manage the Tailwind "watch" process from `rails server`. (#300) @npezza93
* Lazily load the debugger gem when running `bin/dev` (#292) @elia
* Allow choosing a custom port with a `PORT` environment variable when running `bin/dev` (#292) @elia


## v2.1.0 / 2023-12-19

* Update to [Tailwind CSS v3.4.0](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.4.0) from v3.3.6 by @flavorjones


## v2.0.33 / 2023-12-09

* Update to [Tailwind CSS v3.3.6](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.3.6) from v3.3.5 by @flavorjones


## v2.0.32 / 2023-10-27

* Update to [Tailwind CSS v3.3.5](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.3.5) from v3.3.3 by @flavorjones
  * Also see [v3.3.4 release notes](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.3.4)
* Restore support for Ruby 2.7, broken in v2.0.31, by explicitly setting `required_rubygems_version = ">= 3.2.0"`. (#286) by @flavorjones


## v2.0.31 / 2023-10-10

* Update Procfile.dev to run foreman with `--open` option allowing remote sessions with `rdbg --attach` (#281) by @duduribeiro
* Address Rubygems 3.5.0 deprecation warnings (#280) by @lylo


## v2.0.30 / 2023-07-13

* Update to [Tailwind CSS v3.3.3](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.3.3) by @flavorjones
* If defined, the `spec:prepare` rake task will be decorated with `tailwindcss:build` (#271) by @rmehner


## v2.0.29 / 2023-04-26

* Update to [Tailwind CSS v3.3.2](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.3.2) by @flavorjones


## v2.0.28 / 2023-04-21

* The `watch` task accepts an `always` argument to keep the watcher alive when stdin is closed: `rails tailwindcss:watch[always]`. #262 by @GoodForOneFare


## v2.0.27 / 2023-04-02

* Update to [Tailwind CSS v3.3.1](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.3.1) by @flavorjones


## v2.0.26 / 2023-03-30

* Update to [Tailwind CSS v3.3.0](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.3.0) by @tysongach
* Use a locally-installed `tailwindcss` executable by setting a `TAILWINDCSS_INSTALL_DIR` environment variable. (#224, #226) by @flavorjones


## v2.0.25 / 2023-03-14

* Installer now includes all 5 official Tailwind plugins (adding `line-clamp` and `container-queries`). (#254) by @Kentasmic


## v2.0.24 / 2023-03-05

* When Rails CSS compression is on, avoid generating minified tailwindcss assets. (#253) by [@flavorjones](https://github.com/flavorjones).


## v2.0.23 / 2023-02-19

* Update to [Tailwind CSS v3.2.7](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.2.7) by [@flavorjones](https://github.com/flavorjones).


## v2.0.22 / 2023-02-08

* Update to [Tailwind CSS v3.2.6](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.2.6) by [@flavorjones](https://github.com/flavorjones).
* Introduce a `verbose` task argument, and put verbose logging behind it by [@ghiculescu](https://github.com/ghiculescu).
* Fix scaffold view generation for nested models (#227) by [@dixpac](https://github.com/dixpac).
* Improved documentation by [@ghiculescu](https://github.com/ghiculescu) and [@flavorjones](https://github.com/flavorjones).


## v2.0.21 / 2022-11-11

* Update to [Tailwind CSS v3.2.4](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.2.4) by [@flavorjones](https://github.com/flavorjones).


## v2.0.20 / 2022-11-10

* Update to [Tailwind CSS v3.2.3](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.2.3) by [@willcosgrove](https://github.com/willcosgrove).


## v2.0.19 / 2022-11-08

* Update `bin/dev` script to stay in sync with other Rails installers' versions (e.g, `cssbundling-rails` and `dartsass-rails`). Use `sh` instead of `bash` for vanilla Alpine support, and use `exec` to run foreman for better interrupt handling. [#219](https://github.com/rails/tailwindcss-rails/pull/219) by [@marcoroth](https://github.com/marcoroth).


## v2.0.18 / 2022-11-07

* Update to [Tailwind CSS v3.2.2](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.2.2) by [@AlexKovynev](https://github.com/AlexKovynev).


## v2.0.17 / 2022-11-01

* Add `arm-linux` support. [#218](https://github.com/rails/tailwindcss-rails/pull/218) by [@flavorjones](https://github.com/flavorjones).


## v2.0.16 / 2022-10-21

* Update to [Tailwind CSS v3.2.1](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.2.1) by [@AlexKovynev](https://github.com/AlexKovynev) in [#213](https://github.com/rails/tailwindcss-rails/pull/213).


## v2.0.15 / 2022-10-20

* Update to [Tailwind CSS v3.2.0](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.2.0) by [@domchristie](https://github.com/domchristie) in [#209](https://github.com/rails/tailwindcss-rails/pull/209).


## v2.0.14 / 2022-09-19

* Work around [upstream rubygems issue](https://github.com/rubygems/rubygems/issues/5938) on `musl` platforms. [[#200](https://github.com/rails/tailwindcss-rails/issues/200)]


## v2.0.13 / 2022-09-05

* Correctly handle paths with embedded spaces. [#184](https://github.com/rails/tailwindcss-rails/issues/184) by [@flavorjones](https://github.com/flavorjones)
* The `build` and `watch` tasks accept a `debug` argument to generate unminified assets: `rails tailwindcss:build[debug]` or `rails tailwindcss:watch[debug]`. [#198](https://github.com/rails/tailwindcss-rails/pull/198) by [@flavorjones](https://github.com/flavorjones)
* The `watch` task accepts a `poll` argument to use polling instead of file system events: `rails tailwindcss:watch[poll]`. [#199](https://github.com/rails/tailwindcss-rails/pull/199) by [@flavorjones](https://github.com/flavorjones)


## v2.0.12 / 2022-08-10

* Address issue when running commands with #exec by [@blerchin](https://github.com/blerchin) in [#189](https://github.com/rails/tailwindcss-rails/issues/189)


## v2.0.11 / 2022-08-09

* Use exec to run tailwind binary, so return codes pass through by [@blerchin](https://github.com/blerchin) in [#181](https://github.com/rails/tailwindcss-rails/issues/181)
* Update to Tailwind CSS v3.1.8 by [@TastyPi](https://github.com/TastyPi) in [#186](https://github.com/rails/tailwindcss-rails/issues/186)


## v2.0.10 / 2022-06-19

* Fixed that released gems include the correct version of Tailwind CSS (3.1.3, not 3.0.3) by [@dhh](https://github.com/dhh) 


## v2.0.9 / 2022-06-18

* Update to Tailwind CSS v3.1.3 by [@cover](https://github.com/cover) in [#174](https://github.com/rails/tailwindcss-rails/issues/174)
* Add the `public/*.html` path to tailwind content config: by [@Edouard-chin](https://github.com/Edouard-chin) in [#178](https://github.com/rails/tailwindcss-rails/issues/178)
* Allow for spaces in the working directory for build/watch task by [@rakaur](https://github.com/rakaur) in [#176](https://github.com/rails/tailwindcss-rails/issues/176)
* support x64-mingw-ucrt for Ruby 3.1 users ([#172](https://github.com/rails/tailwindcss-rails/issues/172)) by [@flavorjones](https://github.com/flavorjones) in [#173](https://github.com/rails/tailwindcss-rails/issues/173)


## v2.0.8 / 2022-03-10

* Restrict views to common template formats by [@pixeltrix](https://github.com/pixeltrix) in [#155](https://github.com/rails/tailwindcss-rails/issues/155)
* Update rake build command to work with Windows by [@pietmichal](https://github.com/pietmichal) in [#156](https://github.com/rails/tailwindcss-rails/issues/156)
* Upgrade to Tailwind 3.0.23 by [@dhh](https://github.com/dhh) 


## v2.0.7 / 2022-02-22

* Installer: don't add main in existing projects by [@shafy](https://github.com/shafy) in [#146](https://github.com/rails/tailwindcss-rails/issues/146)
* Delete legacy tailwind.css by [@HusseinMorsy](https://github.com/HusseinMorsy) in [#148](https://github.com/rails/tailwindcss-rails/issues/148)


## v2.0.6 / 2022-02-19

* Update tailwindcss to v3.0.22 by [@dukex](https://github.com/dukex) in [#143](https://github.com/rails/tailwindcss-rails/issues/143)
* Minify output by default by [@dhh](https://github.com/dhh) in [c76f5d22](https://github.com/rails/tailwindcss-rails/commit/c76f5d22f9344d1ffe205352f189b75d3871d78e)


## v2.0.5 / 2022-01-16

* Upgrade to Tailwind CSS v3.0.15
* Fix: Insert centring container around the yield by [@dixpac](https://github.com/dixpac) in [#106](https://github.com/rails/tailwindcss-rails/issues/106)
* Add description to watch task by [@RolandStuder](https://github.com/RolandStuder) in [#130](https://github.com/rails/tailwindcss-rails/issues/130)
* Fix the wrong indentation by [@dixpac](https://github.com/dixpac) in [#132](https://github.com/rails/tailwindcss-rails/issues/132)


## v2.0.3 / 2022-01-03

* fix: name the platform using just architecture and os by [@flavorjones](https://github.com/flavorjones) in [#103](https://github.com/rails/tailwindcss-rails/issues/103)
* Add tailwindcss-linux-arm64 support (make docker on Apple Silicon M1 workflow possible) by [@schmidp](https://github.com/schmidp) in [#112](https://github.com/rails/tailwindcss-rails/issues/112)

### New Contributors
* [@schmidp](https://github.com/schmidp) made their first contribution in [#112](https://github.com/rails/tailwindcss-rails/issues/112)


## v2.0.2 / 2021-12-19

* Upgrade to [Tailwind CSS 3.0.7](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.0.7) by [@dhh](https://github.com/dhh) 
* Remove setting the `dark-mode` explicitly by [@dixpac](https://github.com/dixpac) in [#100](https://github.com/rails/tailwindcss-rails/issues/100)


## v2.0.1 / 2021-12-19

* Remove redundant font-size class from generators by [@marcushwz](https://github.com/marcushwz) in [#97](https://github.com/rails/tailwindcss-rails/issues/97)
* Add error messages on unsupported platforms or when bundler platforms aren't correct by [@flavorjones](https://github.com/flavorjones) in [#102](https://github.com/rails/tailwindcss-rails/issues/102)


## v2.0.0 / 2021-12-18

Tailwind CSS for Rails now uses [the standalone executables made for Tailwind 3](https://tailwindcss.com/blog/standalone-cli). These executables are platform specific, so there's actually separate underlying gems per platform, but the correct gem will automatically be picked for your platform. Supported platforms are Linux x64, macOS arm64, macOS x64, and Windows x64. (Note that due to this setup, you must install the actual gems – you can't pin your gem to the github repo.)

This is a completely different approach from previous versions of tailwindcss-rails. Gone is Ruby-powered purger. Everything now works as it would if you had installed the Node version of Tailwind. But without the Node!

This setup requires a separate watch process to run, which is configured and modeled after the approach used in [cssbundling-rails](https://github.com/rails/cssbundling-rails). Look at the README for more details.

Huge thanks to [@flavorjones](https://github.com/flavorjones) for creating the platform-specific gem setup 🙏


## v1.0.0 / 2021-12-14

Nothing. But we're promote 0.5.4 to 1.0.0 to go along with the final release of Rails 7.0. Because as a new sanctioned default option of Rails 7, we should stick to the API, and this communicates that 🚀🥳


## v0.5.4 / 2021-12-03

* Only depends on the `railties` gem.


## v0.5.3 / 2021-12-03

* Match button label for destroy with text used by regular Rails templates by [@dhh](https://github.com/dhh)


