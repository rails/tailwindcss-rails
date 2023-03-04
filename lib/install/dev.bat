@echo off

set gem_installed=

for /f "delims=" %%a in ('gem list foreman -i') do @set gem_installed=%%a

if %gem_installed%==false (
  echo "Installing foreman..."
  gem install foreman
)

foreman start -f Procfile.dev %*