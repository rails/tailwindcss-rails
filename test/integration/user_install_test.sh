#! /usr/bin/env bash
# reproduce the documented user journey for installing and running tailwindcss-rails
# this is run in the CI pipeline, non-zero exit code indicates a failure

set -o pipefail
set -eux

# set up dependencies
rm -f Gemfile.lock
bundle remove actionmailer || true
bundle remove rails || true
bundle add rails --skip-install ${RAILSOPTS:-}
bundle install --prefer-local
bundle exec rails -v

# do our work a directory with spaces in the name (#176, #184)
rm -rf "My Workspace"
mkdir "My Workspace"
pushd "My Workspace"

function prepare_deps {
  # make sure to use the same version of rails (e.g., install from git source if necessary)
  bundle remove rails --skip-install
  bundle add rails --skip-install ${RAILSOPTS:-}

  # use the tailwindcss-rails under test
  bundle add tailwindcss-rails --skip-install --path="../.."
  bundle add tailwindcss-ruby --skip-install ${TAILWINDCSSOPTS:-}
  bundle install --prefer-local
  bundle show --paths | fgrep tailwind
  bundle binstubs --all
}

function install_tailwindcss {
  # install tailwindcss
  bin/rails tailwindcss:install

  # TEST: tailwind was installed correctly
  grep -q "<main class=\"container" app/views/layouts/application.html.erb
  test -a app/assets/tailwind/application.css
}

# Application variation #1 ----------------------------------------
bundle exec rails new test-install --skip-bundle
pushd test-install

prepare_deps
install_tailwindcss

# TEST: rake tasks don't exec (#188)
cat <<EOF >> Rakefile
task :still_here do
  puts "Rake process did not exit early"
end
EOF

cat >> app/assets/tailwind/application.css <<EOF
@theme static { --color-special: #abc12399; }
EOF

bin/rails tailwindcss:build still_here | grep "Rake process did not exit early"

if [[ $(rails -v) > "Rails 8.0.0.beta" ]] ; then
  # TEST: presence of the generated file
  bin/rails generate authentication
  grep -q PasswordsController app/controllers/passwords_controller.rb
fi

# TEST: presence of the generated file
bin/rails generate scaffold post title:string body:text published:boolean
grep -q "Show" app/views/posts/index.html.erb

# TEST: the "accept_confirm" system test change was applied cleanly
grep -q "accept_confirm { click_on \"Destroy this post\"" test/system/posts_test.rb

# TEST: contents of the css file
bin/rails tailwindcss:build[verbose]
grep -q "py-2" app/assets/builds/tailwind.css

# TEST: contents include application.css directives
grep -q "#abc12399" app/assets/builds/tailwind.css

# Application variation #2 ----------------------------------------
popd
bundle exec rails new test-install2 --skip-bundle --skip-system-test
pushd test-install2

prepare_deps
install_tailwindcss

# TEST: presence of the generated file
# TEST: nothing blew up without system tests, https://github.com/rails/tailwindcss-rails/issues/559
bin/rails generate scaffold post title:string body:text published:boolean
grep -q "Show" app/views/posts/index.html.erb

echo "OK"
