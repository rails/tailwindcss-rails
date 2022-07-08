TAILWIND_COMPILE_COMMAND = "#{RbConfig.ruby} #{Pathname.new(__dir__).to_s}/../../exe/tailwindcss -i '#{Rails.root.join("app/assets/stylesheets/application.tailwind.css")}' -o '#{Rails.root.join("app/assets/builds/tailwind.css")}' -c '#{Rails.root.join("config/tailwind.config.js")}' --minify"

namespace :tailwindcss do
  desc "Install tailwind plugins"
  task :install_plugins do
    plugins = YAML.load_file(Rails.root.join("config", "tailwind.plugins.yml"))

    next unless plugins

    plugins.each do |name, url|
      dir = Rails.root.join("tmp", "tailwindcss-plugin").to_s

      next if File.exists?(File.join(dir, "#{name}.css"))
      FileUtils.mkdir_p(dir)

      URI.open(url) do |remote|
        File.open(File.join(dir, "#{name}.css"), "wb") do |local|
          local.write(remote.read)
        end
      end
    end
  end

  desc "Build your Tailwind CSS"
  task :build do
    exec TAILWIND_COMPILE_COMMAND
  end

  desc "Watch and build your Tailwind CSS on file changes"
  task :watch do
    exec "#{TAILWIND_COMPILE_COMMAND} -w"
  end
end

Rake::Task["tailwindcss:watch"].enhance(["tailwindcss:install_plugins"])
Rake::Task["tailwindcss:build"].enhance(["tailwindcss:install_plugins"])

Rake::Task["assets:precompile"].enhance(["tailwindcss:build"])

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["tailwindcss:build"])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance(["tailwindcss:build"])
end
