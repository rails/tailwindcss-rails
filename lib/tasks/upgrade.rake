namespace :tailwindcss do
  desc "Upgrade app from Tailwind CSS v3 to v4"
  task :upgrade do
    system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../install/upgrade_tailwindcss.rb", __dir__)}"
  end
end
