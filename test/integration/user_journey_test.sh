#! /usr/bin/env bash
# reproduce the documented user journey for installing and running tailwindcss-rails
# this is run in the CI pipeline, non-zero exit code indicates a failure

set -o pipefail
set -eux

# fetch the upstream executables
bundle exec rake download

# create a rails app in a directory with spaces in the name (#176, #184)
rm -rf "Has A Space"
mkdir "Has A Space"
pushd "Has A Space"

gem install rails
rails new test-app --skip-bundle
pushd test-app

# install tailwindcss-rails
bundle add tailwindcss-rails --path="../.."
bundle install

bin/rails tailwindcss:install

# ensure rake tasks don't exec (#188)
bin/rails tailwindcss:build about | grep "About your application"
