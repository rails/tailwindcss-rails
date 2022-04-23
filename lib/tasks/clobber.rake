namespace :tailwindcss do
  desc "Remove CSS builds"
  task :clobber do
    rm_rf Dir["app/assets/builds/[^.]*.css"], verbose: false
  end
end

Rake::Task["assets:clobber"].enhance(["tailwindcss:clobber"]) if Rake::Task.task_defined?('assets:precompile') && Rake::Task.task_defined?('clober_assets')
