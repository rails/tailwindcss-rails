#! /usr/bin/env bash
# reproduce the documented user journey for installing and running tailwindcss-rails
# this is run in the CI pipeline, non-zero exit code indicates a failure

set -o pipefail
set -eux

# set up dependencies
rm -f Gemfile.lock
bundle remove actionmailer
bundle add rails --skip-install ${RAILSOPTS:-}
bundle install --prefer-local

# do our work a directory with spaces in the name (#176, #184)
rm -rf "My Workspace"
mkdir "My Workspace"
pushd "My Workspace"

# create a rails app
bundle exec rails -v
bundle exec rails new test-upgrade --skip-bundle
pushd test-upgrade

# make sure to use the same version of rails (e.g., install from git source if necessary)
bundle remove rails --skip-install
bundle add rails --skip-install ${RAILSOPTS:-}

# set up app with tailwindcss-rails v3 and tailwindcss-ruby v3
bundle add tailwindcss-rails --skip-install --version 3.3.0
bundle add tailwindcss-ruby  --skip-install --version 3.4.17
bundle install --prefer-local
bundle show --paths
bundle binstubs --all

# install tailwindcss
bin/rails tailwindcss:install
grep -q inter-font app/views/layouts/application.html.erb

if [[ $(rails -v) > "Rails 8.0.0.beta" ]] ; then
  # install auth templates
  bin/rails generate authentication
  grep -q PasswordsController app/controllers/passwords_controller.rb
fi

# install scaffold templates
bin/rails generate scaffold post title:string body:text published:boolean
grep -q "Show this post" app/views/posts/index.html.erb

# upgrade time!
bundle remove tailwindcss-rails --skip-install
bundle remove tailwindcss-ruby --skip-install

bundle add tailwindcss-rails --skip-install --path="../.."
bundle add tailwindcss-ruby  --skip-install --version 4.0.0

bundle install --prefer-local
bundle show --paths
bundle binstubs --all

bin/rails tailwindcss:upgrade

# TEST: removal of inter-font CSS
if grep -q inter-font app/views/layouts/application.html.erb ; then
  echo "FAIL: inter-font CSS not removed"
  exit 1
fi

# generate CSS
bin/rails tailwindcss:build[verbose]
grep -q "py-2" app/assets/builds/tailwind.css

echo "OK"
