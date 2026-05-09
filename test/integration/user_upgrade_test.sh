#! /usr/bin/env bash
# reproduce the documented user journey for installing and running tailwindcss-rails
# this is run in the CI pipeline, non-zero exit code indicates a failure

set -o pipefail
set -eux

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WORKDIR="$ROOT/tmp/integration-user-upgrade"

rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
pushd "$WORKDIR"

# set up dependencies in a fresh Gemfile
gem install bcrypt # it's complicated, see Rails 7549ba77. can probably be removed once Rails 8.0 is EOL.
cat > Gemfile <<EOF
source "https://rubygems.org"
EOF
bundle add rails --skip-install ${RAILSOPTS:-}
bundle install --prefer-local

# do our work in a directory with spaces in the name (#176, #184)
mkdir "My Workspace"
pushd "My Workspace"

# create a rails app
bundle exec rails -v
bundle exec rails new test-upgrade --skip-bundle
pushd test-upgrade

# make sure to use the same version of rails (e.g., install from git source if necessary)
bundle remove rails --skip-install
rm -f Gemfile.lock
bundle add rails --skip-install ${RAILSOPTS:-}

# set up app with tailwindcss-rails v3 and tailwindcss-ruby v3
bundle add tailwindcss-rails --skip-install --version 3.3.0
bundle add tailwindcss-ruby  --skip-install --version 3.4.17
bundle install --prefer-local
bundle show --paths | fgrep tailwind
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

bundle add tailwindcss-rails --skip-install --path="$ROOT"
bundle add tailwindcss-ruby --skip-install ${TAILWINDCSSOPTS:---version 4.0.0}

bundle install --prefer-local
bundle show --paths | fgrep tailwind
bundle binstubs --all

# create a postcss file
cat <<EOF > config/postcss.config.js
module.exports = {
  plugins: {
    autoprefixer: {},
  },
}
EOF

bin/rails tailwindcss:upgrade

# TEST: removal of inter-font CSS
if grep -q inter-font app/views/layouts/application.html.erb ; then
  echo "FAIL: inter-font CSS not removed"
  exit 1
fi

# TEST: moving the postcss file
test ! -a config/postcss.config.js
test   -a postcss.config.js

# TEST: moving application.tailwind.css
test ! -a app/assets/stylesheets/application.tailwind.css
test   -a app/assets/tailwind/application.css

# generate CSS
bin/rails tailwindcss:build[verbose]
grep -q "py-2" app/assets/builds/tailwind.css

echo "OK"
