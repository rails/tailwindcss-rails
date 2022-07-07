namespace :tailwindcss do
  desc "Remove CSS builds"
  task :clobber do
    rm_rf Dir["app/assets/builds/[^.]*.css"], verbose: false
    rm_rf Dir["tmp/tailwindcss-plugin/[^.]*.css"], verbose: false
  end
end

Rake::Task["assets:clobber"].enhance(["tailwindcss:clobber"])
