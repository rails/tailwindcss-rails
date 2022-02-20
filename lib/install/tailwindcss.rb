APPLICATION_LAYOUT_PATH             = Rails.root.join("app/views/layouts/application.html.erb")
CENTERING_CONTAINER_INSERTION_POINT = /^\s*<%= yield %>/.freeze

if APPLICATION_LAYOUT_PATH.exist?
  say "Add Tailwindcss include tags and container element in application layout"
  insert_into_file APPLICATION_LAYOUT_PATH.to_s, <<~ERB.indent(4), before: /^\s*<%= stylesheet_link_tag/
    <%= stylesheet_link_tag "tailwind", "inter-font", "data-turbo-track": "reload" %>
  ERB

  if File.open(APPLICATION_LAYOUT_PATH).read =~ /<body>\n\s*<%= yield %>\n\s*<\/body>/
    insert_into_file APPLICATION_LAYOUT_PATH.to_s, %(    <main class="container mx-auto mt-28 px-5 flex">\n  ), before: CENTERING_CONTAINER_INSERTION_POINT
    insert_into_file APPLICATION_LAYOUT_PATH.to_s, %(\n    </main>),  after: CENTERING_CONTAINER_INSERTION_POINT
  end
else
  say "Default application.html.erb is missing!", :red
  say %(        Add <%= stylesheet_link_tag "tailwind", "inter-font", "data-turbo-track": "reload" %> within the <head> tag in your custom layout.)
end

say "Build into app/assets/builds"
empty_directory "app/assets/builds"
keep_file "app/assets/builds"

if (sprockets_manifest_path = Rails.root.join("app/assets/config/manifest.js")).exist?
  append_to_file sprockets_manifest_path, %(//= link_tree ../builds\n)
end

if Rails.root.join(".gitignore").exist?
  append_to_file(".gitignore", %(\n/app/assets/builds/*\n!/app/assets/builds/.keep\n))
end

unless Rails.root.join("config/tailwind.config.js").exist?
  say "Add default config/tailwindcss.config.js"
  copy_file "#{__dir__}/tailwind.config.js", "config/tailwind.config.js"
end

unless Rails.root.join("app/assets/stylesheets/application.tailwind.css").exist?
  say "Add default app/assets/stylesheets/application.tailwind.css"
  copy_file "#{__dir__}/application.tailwind.css", "app/assets/stylesheets/application.tailwind.css"
end

if Rails.root.join("Procfile.dev").exist?
  append_to_file "Procfile.dev", "css: bin/rails tailwindcss:watch\n"
else
  say "Add default Procfile.dev"
  copy_file "#{__dir__}/Procfile.dev", "Procfile.dev"

  say "Ensure foreman is installed"
  run "gem install foreman"
end

say "Add bin/dev to start foreman"
copy_file "#{__dir__}/dev", "bin/dev"
chmod "bin/dev", 0755, verbose: false

say "Compile initial Tailwind build"
run "rails tailwindcss:build"
