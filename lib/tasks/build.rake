namespace :tailwindcss do
  desc "Build your Tailwind CSS"
  task :build do |_, args|
    debug = args.extras.include?("debug")
    glob = "*.tailwind.css"

    files = Rails.root.join("app/assets/stylesheets").glob(glob)

    if files.count == 1 && files.first.basename == "application.tailwind.css"
      command = Tailwindcss::Commands.compile_command(debug: debug)
      puts command.inspect
      system(*command, exception: true)
    else
      files.map do |file|
        Tailwindcss::Commands.compile_file_command(file: file, glob: glob, debug: debug)
      end.each do |command|
        puts command.join(" ")
        system(*command, exception: true)
      end
    end
  end

  desc "Watch and build your Tailwind CSS on file changes"
  task :watch do |_, args|
    debug = args.extras.include?("debug")
    poll = args.extras.include?("poll")
    glob = args.extras.include?("glob") ? "*.tailwind.css" : nil

    if glob
      trap("SIGINT") { exit }

      Rails.root.join("app/assets/stylesheets").glob(glob).map do |file|
        Tailwindcss::Commands.watch_file_command(file: file, glob: glob, debug: debug, poll: poll)
      end.each do |command|
        fork do
          puts command.join(" ")
          system(*command)
        end
      end
    else
      command = Tailwindcss::Commands.watch_command(debug: debug, poll: poll)
      puts command.inspect
      system(*command)
    end
  end
end

Rake::Task["assets:precompile"].enhance(["tailwindcss:build"])

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["tailwindcss:build"])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance(["tailwindcss:build"])
end
