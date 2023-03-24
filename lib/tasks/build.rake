namespace :tailwindcss do
  desc "Build your Tailwind CSS"
  task build: :environment do |_, args|
    debug = args.extras.include?("debug")

    files = Rails.root.join("app/assets/stylesheets").glob("*.tailwind.css")

    if files.count == 1 && files.first.basename == "application.tailwind.css"
      command = Tailwindcss::Commands.compile_command(debug: debug)
      puts command.join(" ")
      system(*command, exception: true)
    else
      files.map do |file|
        Tailwindcss::Commands.compile_file_command(file: file, debug: debug)
      end.each do |command|
        puts command.join(" ")
        system(*command, exception: true)
      end
    end
  end

  desc "Watch and build your Tailwind CSS on file changes"
  task watch: :environment do |_, args|
    debug = args.extras.include?("debug")
    poll = args.extras.include?("poll")

    files = Rails.root.join("app/assets/stylesheets").glob("*.tailwind.css")

    if files.count == 1 && files.first.basename == "application.tailwind.css"
      command = Tailwindcss::Commands.watch_command(debug: debug, poll: poll)
      puts command.join(" ")
      system(*command)
    else
      trap("SIGINT") { exit }

      files.map do |file|
        Tailwindcss::Commands.watch_file_command(file: file, debug: debug, poll: poll)
      end.each do |command|
        fork do
          puts command.join(" ")
          system(*command)
        end
      end
    end
  end
end

Rake::Task["assets:precompile"].enhance(["tailwindcss:build"])

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["tailwindcss:build"])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance(["tailwindcss:build"])
end
