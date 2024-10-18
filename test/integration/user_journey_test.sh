#! /usr/bin/env bash
# reproduce the documented user journey for installing and running tailwindcss-rails
# this is run in the CI pipeline, non-zero exit code indicates a failure

set -o pipefail
set -eux

# set up dependencies
rm -f Gemfile.lock
bundle remove actionmailer
bundle add rails --skip-install ${RAILSOPTS:-}
bundle install

# do our work a directory with spaces in the name (#176, #184)
rm -rf "My Workspace"
mkdir "My Workspace"
pushd "My Workspace"

# create a rails app
bundle exec rails -v
bundle exec rails new test-app --skip-bundle
pushd test-app

# make sure to use the same version of rails (e.g., install from git source if necessary)
bundle remove rails --skip-install
bundle add rails --skip-install ${RAILSOPTS:-}

# use the tailwindcss-rails under test
bundle add tailwindcss-rails --skip-install --path="../.."
bundle add tailwindcss-ruby --skip-install ${TAILWINDCSSOPTS:-}
bundle install
bundle show --paths
bundle binstubs --all

# install tailwindcss
bin/rails tailwindcss:install

# TEST: tailwind was installed correctly
grep -q tailwind app/views/layouts/application.html.erb

# TEST: rake tasks don't exec (#188)
cat <<EOF >> Rakefile
task :still_here do
  puts "Rake process did not exit early"
end
EOF

bin/rails tailwindcss:build still_here | grep "Rake process did not exit early"

if [[ $(rails -v) > "Rails 8.0.0.beta" ]] ; then
  # TEST: presence of the generated file
  bin/rails generate authentication
  grep -q PasswordsController app/controllers/passwords_controller.rb
fi

# TEST: presence of the generated file
bin/rails generate scaffold post title:string body:text published:boolean
grep -q "Show this post" app/views/posts/index.html.erb

# TEST: contents of the css file
bin/rails tailwindcss:build[verbose]
grep -q "py-2" app/assets/builds/tailwind.css

# TEST: edit the css file by adding a custom property to the @theme block 
tailwind_application_css_file_path="app/assets/stylesheets/application.tailwind.css"
echo -e "\n@theme { --color-tomato: #fafafa; }" >> "$tailwind_application_css_file_path"

bin/rails tailwindcss:build[verbose]
grep -q "fafafa" app/assets/builds/tailwind.css

echo "OK"
