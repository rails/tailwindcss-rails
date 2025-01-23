TAILWIND_CONFIG_PATH = Rails.root.join("config/tailwind.config.js")
APPLICATION_LAYOUT_PATH = Rails.root.join("app/views/layouts/application.html.erb")
POSTCSS_CONFIG_PATH = Rails.root.join("config/postcss.config.js")

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
  FileUtils.mv(POSTCSS_CONFIG_PATH, Rails.root, verbose: true) || abort
end

if system("npx --version")
  say "Running the upstream Tailwind CSS upgrader"
  command = Shellwords.join(["npx", "@tailwindcss/upgrade@next", "--force", "--config", TAILWIND_CONFIG_PATH.to_s])
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

if APPLICATION_LAYOUT_PATH.exist?
  if File.read(APPLICATION_LAYOUT_PATH).match?(/"inter-font"/)
    say "Strip Inter font CSS from application layout"
    gsub_file APPLICATION_LAYOUT_PATH.to_s, %r{, "inter-font"}, ""
  else
    say "Inter font CSS not detected.", :green
  end
else
  say "Default application.html.erb is missing!", :red
  say %(        Please check your layouts and remove any "inter-font" stylesheet links.)
end

say "Compile initial Tailwind build"
run "rails tailwindcss:build"
