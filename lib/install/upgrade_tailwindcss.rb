TAILWIND_CONFIG_PATH = Rails.root.join("config/tailwind.config.js")
APPLICATION_LAYOUT_PATH = Rails.root.join("app/views/layouts/application.html.erb")
POSTCSS_CONFIG_PATH = Rails.root.join("config/postcss.config.js")
OLD_TAILWIND_ASSET_PATH = Rails.root.join("app/assets/stylesheets/application.tailwind.css")
TAILWIND_ASSET_PATH = Rails.root.join("app/assets/tailwind/application.css")

unless TAILWIND_CONFIG_PATH.exist?
  say "Default tailwind.config.js is missing!", :red
  abort
end

if File.read(TAILWIND_CONFIG_PATH).match?(/defaultTheme/)
  say "Removing references to 'defaultTheme' from #{TAILWIND_CONFIG_PATH}"
  gsub_file TAILWIND_CONFIG_PATH.to_s, /^(.*defaultTheme)/, "// \\1"
end

if POSTCSS_CONFIG_PATH.exist?
  say "Moving PostCSS configuration to application root directory"
  copy_file POSTCSS_CONFIG_PATH, Rails.root.join("postcss.config.js")
  remove_file POSTCSS_CONFIG_PATH
end

if APPLICATION_LAYOUT_PATH.exist?
  if File.read(APPLICATION_LAYOUT_PATH).match?(/"inter-font"/)
    say "Strip Inter font CSS from application layout"
    gsub_file APPLICATION_LAYOUT_PATH.to_s, %r{, "inter-font"}, ""
  else
    say "Inter font CSS not detected.", :green
  end

  if File.read(APPLICATION_LAYOUT_PATH).match?(/stylesheet_link_tag :app/) &&
     File.read(APPLICATION_LAYOUT_PATH).match?(/stylesheet_link_tag "tailwind"/)
    say "Remove unnecessary stylesheet_link_tag from application layout"
    gsub_file APPLICATION_LAYOUT_PATH.to_s, %r{^\s*<%= stylesheet_link_tag "tailwind".*%>$}, ""
  end
else
  say "Default application.html.erb is missing!", :red
  say %(        Please check your layouts and remove any "inter-font" stylesheet links.)
end

if OLD_TAILWIND_ASSET_PATH.exist?
  say "Moving #{OLD_TAILWIND_ASSET_PATH} to #{TAILWIND_ASSET_PATH}"
  copy_file OLD_TAILWIND_ASSET_PATH, TAILWIND_ASSET_PATH
  remove_file OLD_TAILWIND_ASSET_PATH
end

if system("npx --version")
  # We're pinning to v4.1.4 because v4.1.5 of the upgrade tool introduces a dependency version check
  # on tailwind and I haven't been able to figure out how to get that to work reliably and I am
  # extremely frustrated with the whole thing. See #544
  #
  # At some point we will probably need to unpin this at which point I am sincerely hoping that
  # someone else will do it.
  say "Running the upstream Tailwind CSS upgrader"
  command = Shellwords.join(["npx", "@tailwindcss/upgrade@4.1.4", "--force", "--config", TAILWIND_CONFIG_PATH.to_s])
  success = run(command, abort_on_failure: false)
  unless success
    say "The upgrade tool failed!", :red
    say %(        You probably need to update your configuration. Please read the error messages,)
    say %(        and check the Tailwind CSS upgrade guide at https://tailwindcss.com/docs/upgrade-guide.)
    abort
  end
else
  say "Could not run the Tailwind upgrade tool. Please see https://tailwindcss.com/docs/upgrade-guide for manual instructions.", :red
  abort
end

say "Compile initial Tailwind build"
run "rails tailwindcss:build"
