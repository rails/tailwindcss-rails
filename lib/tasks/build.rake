namespace :tailwindcss do
  desc "Build your Tailwind CSS"
  task build: [:environment, :engines] do |_, args|
    debug = args.extras.include?("debug")
    silent = args.extras.include?("silent")
    verbose = args.extras.include?("verbose")

    command = Tailwindcss::Commands.compile_command(debug: debug, silent: silent)
    env = Tailwindcss::Commands.command_env(verbose: verbose)
    puts "Running: #{Shellwords.join(command)}" if verbose

    system(env, *command, exception: true)
  end

  desc "Watch and build your Tailwind CSS on file changes"
  task watch: [:environment, :engines] do |_, args|
    debug = args.extras.include?("debug")
    always = args.extras.include?("always")
    silent = args.extras.include?("silent")
    verbose = args.extras.include?("verbose")

    command = Tailwindcss::Commands.watch_command(always: always, debug: debug, silent: silent)
    env = Tailwindcss::Commands.command_env(verbose: verbose)
    puts "Running: #{Shellwords.join(command)}" if verbose

    received_signal = Tailwindcss::ProcessRunner.spawn_and_wait(env, *command)
    puts "Received #{received_signal}, exiting tailwindcss:watch" if verbose && received_signal
  end

  desc "Create Tailwind CSS entry point files for Rails Engines"
  task engines: :environment do
    Tailwindcss::Engines.bundle
  end
end

unless ENV["TAILWINDCSS_SKIP_BUILD"].present?
  Rake::Task["assets:precompile"].enhance(["tailwindcss:build"])

  if Rake::Task.task_defined?("test:prepare")
    Rake::Task["test:prepare"].enhance(["tailwindcss:build"])
  elsif Rake::Task.task_defined?("spec:prepare")
    Rake::Task["spec:prepare"].enhance(["tailwindcss:build"])
  elsif Rake::Task.task_defined?("db:test:prepare")
    Rake::Task["db:test:prepare"].enhance(["tailwindcss:build"])
  end
end
