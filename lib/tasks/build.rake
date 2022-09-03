namespace :tailwindcss do
  desc "Build your Tailwind CSS"
  task :build do
    command = Tailwindcss::Commands.compile_command
    puts command.inspect
    system(*command, exception: true)
  end

  desc "Watch and build your Tailwind CSS on file changes"
  task :watch do
    command = Tailwindcss::Commands.watch_command
    puts command.inspect
    system(*command)
  end
end

Rake::Task["assets:precompile"].enhance(["tailwindcss:build"])

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["tailwindcss:build"])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance(["tailwindcss:build"])
end
