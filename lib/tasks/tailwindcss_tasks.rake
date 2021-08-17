namespace :tailwindcss do
  desc "Install Tailwind CSS into the app"
  task :install do
    system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../install/tailwindcss.rb", __dir__)}"
  end

  desc "Show the list of class names being kept in Tailwind CSS"
  task :keeping_class_names do
    puts Tailwindcss::Purger.extract_class_names_from(default_files_with_class_names)
  end

  desc "Show Tailwind CSS styles that are left after purging unused class names"
  task :preview_purge do
    puts Tailwindcss::Purger.purge tailwind_css, keeping_class_names_from_files: default_files_with_class_names
  end
end

def default_files_with_class_names
  Rails.root.glob("app/views/**/*.*") + Rails.root.glob("app/helpers/**/*.rb")
end

def tailwind_css
  Pathname.new(__FILE__).join("../../../app/assets/stylesheets/tailwind.css").read
end

