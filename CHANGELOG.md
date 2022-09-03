
## Unreleased

* Correctly handle paths with embedded spaces. [#184](https://github.com/rails/tailwindcss-rails/issues/184)


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


