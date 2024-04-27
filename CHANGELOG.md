## next / unreleased

* Remove the `@tailwindcss/aspect-ratio` plugin from the `tailwind.config.js` that gets installed by the generator. (#344) @flavorjones @searls


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


