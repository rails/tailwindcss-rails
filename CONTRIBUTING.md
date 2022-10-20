# Contributing to tailwindcss-rails

This doc is a brief introduction on modifying and maintaining this gem.

## Updating to the latest upstream tailwindcss version

Update `lib/tailwindcss/upstream.rb` with the upstream version.

Run `bundle exec rake clobber` then `bundle exec rake download` to ensure the tailwindcss binaries can be downloaded, and that you have the correct versions on local disk.

## Cutting a release

- bump the version
  - [ ] update `lib/tailwindcss/version.rb`
  - [ ] update `CHANGELOG.md`
  - [ ] commit and create a git tag
- build the native gems:
  - [ ] `bundle exec rake clobber` to clean up possibly-old tailwindcss executables
  - [ ] `bundle exec rake package`
- push
  - [ ] `for g in pkg/*.gem ; do gem push $g ; done`
  - [ ] `git push`
- announce
  - [ ] create a release at https://github.com/rails/tailwindcss-rails/releases
