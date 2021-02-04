WEBPACK_STYLESHEETS_PATH = "#{Webpacker.config.source_path}/stylesheets"
APPLICATION_LAYOUT_PATH  = Rails.root.join("app/views/layouts/application.html.erb")

say "Installing Tailwind CSS"
run "yarn add tailwindcss@npm:@tailwindcss/postcss7-compat postcss@^7 autoprefixer@^9"
insert_into_file "#{Webpacker.config.source_entry_path}/application.js", "\nimport \"stylesheets/application\"\n"

say "Adding minimal configuration for Tailwind CSS to work properly"
directory Pathname.new(__dir__).join("stylesheets"), Webpacker.config.source_path.join("stylesheets")

insert_into_file "postcss.config.js", "require('tailwindcss'),\n    ", before: "require('postcss-import')"

if APPLICATION_LAYOUT_PATH.exist?
  say "Add Tailwindcss include tags in application layout"
  insert_into_file Rails.root.join("app/views/layouts/application.html.erb").to_s, %(\n    <%= stylesheet_pack_tag "application", "data-turbo-track": "reload" %>), before: /\s*<\/head>/
else
  say "Default application.html.erb is missing!", :red
  say %(        Add <%= stylesheet_pack_tag "application", "data-turbo-track": "reload" %> within the <head> tag in your custom layout.)
end
