APPLICATION_LAYOUT_PATH = Rails.root.join("app/views/layouts/application.html.erb")

if APPLICATION_LAYOUT_PATH.exist?
  say "Add Tailwindcss include tags in application layout"
  insert_into_file APPLICATION_LAYOUT_PATH.to_s, <<~ERB.indent(4), before: /^\s*<%= stylesheet_link_tag/
    <%= stylesheet_link_tag "inter-font", "data-turbo-track": "reload" %>
    <%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %>
  ERB
else
  say "Default application.html.erb is missing!", :red
  say %(        Add <%= stylesheet_link_tag "inter-font", "data-turbo-track": "reload" %> and <%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %> within the <head> tag in your custom layout.)
end

# No longer included by default in Rails 7, but for earlier versions of Rails
if (scaffolds_css_path = Rails.root.join("app/assets/stylesheets/scaffolds.scss")).exist?
  remove_file scaffolds_css_path
end

say "Turn on purging of unused css classes in production"
gsub_file Rails.root.join("config/environments/production.rb"), /^\s+#?\s+config.assets.css_compressor =.*$/, %(  config.assets.css_compressor = :purger)
