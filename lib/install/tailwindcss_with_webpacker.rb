LATEST_WEBPACKER = "\"@rails\/webpacker\": \"rails\/webpacker#b6c2180\",".freeze
TAILWIND_IMPORTS = "@import \"tailwindcss/base\";\n@import \"tailwindcss/components\";\n@import \"tailwindcss/utilities\";\n".freeze

say "Installing Tailwind CSS"

# Current webpacker version relies on an older version of PostCSS
# which the latest TailwindCSS version is not compatible with
gsub_file('package.json', /\"@rails\/webpacker\".*/) { |matched_line| matched_line = LATEST_WEBPACKER }

say "Adding latest tailwind and postcss"
run "yarn add tailwindcss@latest postcss@latest autoprefixer@latest"
insert_into_file "#{Webpacker.config.source_entry_path}/application.js",
                 "\nrequire(\"stylesheets/application.scss\")\n"

say "Adding minimal configuration for TailwindCSS to work properly"
stylesheets_directory = "#{Webpacker.config.source_path}/stylesheets"
empty_directory stylesheets_directory
add_file "#{stylesheets_directory}/application.scss"
insert_into_file "#{stylesheets_directory}/application.scss", TAILWIND_IMPORTS

insert_into_file "postcss.config.js",
                 "require('tailwindcss'),\n\t", before: "require('postcss-import')"

say "Tailwind CSS successfully installed️", :green