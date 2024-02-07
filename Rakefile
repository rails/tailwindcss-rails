require "bundler/setup"

require "bundler/gem_tasks"

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
  t.warning = true
end

task default: :test

namespace "format" do
  desc "Regenerate table of contents in README"
  task "toc" do
    require "mkmf"
    if find_executable0("markdown-toc")
      sh "markdown-toc --maxdepth=3 -i README.md"
    else
      puts "WARN: cannot find markdown-toc, skipping. install with 'npm install markdown-toc'"
    end
  end
end
