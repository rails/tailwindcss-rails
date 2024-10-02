# Contributing to tailwindcss-rails

This doc is a brief introduction on modifying and maintaining this gem.


## Testing this gem

### Running the test suite

The unit tests are run with `bundle exec rake test`

There is an additional integration test which runs in CI, `test/integration/user_journey_test.sh` which you may also want to run.


### Testing in a Rails app

If you want to test modifications to this gem, you must run `rake download` once to download the upstream `tailwindcss` executables.

Then you can point your Rails application's `Gemfile` at the local version of the gem as you normally would:

``` ruby
gem "tailwindcss-rails", path: "/path/to/tailwindcss-rails"
```


## Cutting a release of tailwindcss-rails

- bump the version
  - [ ] update `lib/tailwindcss/version.rb`
  - [ ] update `CHANGELOG.md`
  - [ ] commit and create a git tag
- package and push
  - [ ] `bundle exec rake build`
  - [ ] `gem push pkg/*.gem`
  - [ ] `git push && git push --tags`
- announce
  - [ ] create a release at https://github.com/rails/tailwindcss-rails/releases
