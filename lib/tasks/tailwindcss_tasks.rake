namespace :tailwindcss do
  desc "Install Tailwind CSS into the app"
  task :install do
    if defined?(Webpacker::Engine)
      Rake::Task["tailwindcss:install:webpacker"].invoke
    else
      Rake::Task["tailwindcss:install:asset_pipeline"].invoke
    end
  end

  namespace :install do
    desc "Install Tailwind CSS with the asset pipeline"
    task :asset_pipeline do
      run_install_template "tailwindcss_with_asset_pipeline"
    end

    desc "Install Tailwind CSS with webpacker"
    task :webpacker do
      run_install_template "tailwindcss_with_webpacker"
    end
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

def run_install_template(path)
  system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../install/#{path}.rb", __dir__)}"
end

def default_files_with_class_names
  Rails.root.glob("app/views/**/*.*") + Rails.root.glob("app/helpers/**/*.rb")
end

def tailwind_css
  Pathname.new(__FILE__).join("../../../app/assets/stylesheets/tailwind.css").read
end
