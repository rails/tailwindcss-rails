namespace :tailwindcss do
  desc "Build your Tailwind CSS"
  task build: :environment do |_, args|
    debug = args.extras.include?("debug")
    command = Tailwindcss::Commands.compile_command(debug: debug)
    puts command.inspect if args.extras.include?("verbose")
    system(Tailwindcss::Commands::ENV, *command, exception: true)
  end

  desc "Watch and build your Tailwind CSS on file changes"
  task watch: :environment do |_, args|
    debug = args.extras.include?("debug")
    poll = args.extras.include?("poll")
    always = args.extras.include?("always")
    command = Tailwindcss::Commands.watch_command(always: always, debug: debug, poll: poll)
    puts command.inspect if args.extras.include?("verbose")
    system(Tailwindcss::Commands::ENV, *command)
  rescue Interrupt
    puts "Received interrupt, exiting tailwindcss:watch" if args.extras.include?("verbose")
  end
end

Rake::Task["assets:precompile"].enhance(["tailwindcss:build"])

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["tailwindcss:build"])
elsif Rake::Task.task_defined?("spec:prepare")
  Rake::Task["spec:prepare"].enhance(["tailwindcss:build"])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance(["tailwindcss:build"])
end
