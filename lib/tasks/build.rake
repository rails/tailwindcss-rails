namespace :tailwindcss do
  desc "Build your Tailwind CSS"
  task build: [:environment, :engines] do |_, args|
    debug = args.extras.include?("debug")
    verbose = args.extras.include?("verbose")

    command = Tailwindcss::Commands.compile_command(debug: debug)
    env = Tailwindcss::Commands.command_env(verbose: verbose)
    puts "Running: #{Shellwords.join(command)}" if verbose

    system(env, *command, exception: true)
  end

  desc "Watch and build your Tailwind CSS on file changes"
  task watch: [:environment, :engines] do |_, args|
    debug = args.extras.include?("debug")
    poll = args.extras.include?("poll")
    always = args.extras.include?("always")
    verbose = args.extras.include?("verbose")

    command = Tailwindcss::Commands.watch_command(always: always, debug: debug, poll: poll)
    env = Tailwindcss::Commands.command_env(verbose: verbose)
    puts "Running: #{Shellwords.join(command)}" if verbose

    system(env, *command)
  rescue Interrupt
    puts "Received interrupt, exiting tailwindcss:watch" if args.extras.include?("verbose")
  end

  desc "Create Tailwind CSS entry point files for Rails Engines"
  task engines: :environment do
    Tailwindcss::Engines.bundle
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
