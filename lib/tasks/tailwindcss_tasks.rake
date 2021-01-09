namespace :tailwindcss do
  desc "Install Tailwindcss into the app"
  task :install do
    system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../install/tailwindcss.rb", __dir__)}"
  end

  task :purge do
    Tailwindcss::Purger.new(
      stylesheet_path: Rails.root.join("public/assets").glob("tailwindcss-*.css").first,
      paths_with_css_class_names: [ "app/views/**/*.html*", "app/helpers/**/*.rb" ]
    ).purge
  end
end
