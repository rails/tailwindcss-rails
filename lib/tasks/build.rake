TAILWIND_COMPILE_COMMAND = "#{RbConfig.ruby} #{Pathname.new(__dir__).to_s}/../../exe/tailwindcss -i #{Rails.root.join("app/assets/stylesheets/application.tailwind.css")} -o #{Rails.root.join("app/assets/builds/tailwind.css")} -c #{Rails.root.join("config/tailwind.config.js")} --minify"

namespace :tailwindcss do
  desc "Build your Tailwind CSS"
  task :build do
    system TAILWIND_COMPILE_COMMAND
  end

  desc "Watch and build your Tailwind CSS on file changes"
  task :watch do
    system "#{TAILWIND_COMPILE_COMMAND} -w"
  end
end

Rake::Task["assets:precompile"].enhance(["tailwindcss:build"])

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["tailwindcss:build"])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance(["tailwindcss:build"])
end
