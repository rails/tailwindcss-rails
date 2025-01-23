namespace :tailwindcss do
  desc "Install Tailwind CSS into the app"
  task :install do
    system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../install/install_tailwindcss.rb", __dir__)}"
  end
end
