# coding: utf-8
#
#  Rake tasks to manage native gem packages with binary executables from tailwindlabs/tailwindcss
#
#  TL;DR: run "rake package"
#
#  The native platform gems (defined by Tailwindcss::Upstream::NATIVE_PLATFORMS) will each contain
#  two files in addition to what the vanilla ruby gem contains:
#
#     exe/
#     ├── tailwindcss                             #  generic ruby script to find and run the binary
#     └── <Gem::Platform architecture name>/
#         └── tailwindcss                         #  the tailwindcss binary executable
#
#  The ruby script `exe/tailwindcss` is installed into the user's path, and it simply locates the
#  binary and executes it. Note that this script is required because rubygems requires that
#  executables declared in a gemspec must be Ruby scripts.
#
#  As a concrete example, an x86_64-linux system will see these files on disk after installing
#  tailwindcss-rails-1.x.x-x86_64-linux.gem:
#
#     exe/
#     ├── tailwindcss
#     └── x86_64-linux/
#         └── tailwindcss
#
#  So the full set of gem files created will be:
#
#  - pkg/tailwindcss-rails-1.0.0.gem
#  - pkg/tailwindcss-rails-1.0.0-arm64-darwin.gem
#  - pkg/tailwindcss-rails-1.0.0-x64-mingw32.gem
#  - pkg/tailwindcss-rails-1.0.0-x86_64-darwin.gem
#  - pkg/tailwindcss-rails-1.0.0-x86_64-linux.gem
# 
#  Note that in addition to the native gems, a vanilla "ruby" gem will also be created without
#  either the `exe/tailwindcss` script or a binary executable present.
#
#
#  New rake tasks created:
#
#  - rake gem:ruby           # Build the ruby gem
#  - rake gem:arm64-darwin   # Build the arm64-darwin gem
#  - rake gem:x64-mingw32    # Build the x64-mingw32 gem
#  - rake gem:x86_64-darwin  # Build the x86_64-darwin gem
#  - rake gem:x86_64-linux   # Build the x86_64-linux gem
#  - rake download           # Download all tailwindcss binaries
#
#  Modified rake tasks:
#
#  - rake gem                # Build all the gem files
#  - rake package            # Build all the gem files (same as `gem`)
#  - rake repackage          # Force a rebuild of all the gem files
#
#  Note also that the binary executables will be lazily downloaded when needed, but you can
#  explicitly download them with the `rake download` command.
#
require "rubygems/package_task"
require "open-uri"
require_relative "../lib/tailwindcss/upstream"

def tailwindcss_download_url(filename)
  "https://github.com/tailwindlabs/tailwindcss/releases/download/#{Tailwindcss::Upstream::VERSION}/#{filename}"
end

TAILWINDCSS_RAILS_GEMSPEC = Bundler.load_gemspec("tailwindcss-rails.gemspec")

gem_path = Gem::PackageTask.new(TAILWINDCSS_RAILS_GEMSPEC).define
desc "Build the ruby gem"
task "gem:ruby" => [gem_path]

exepaths = []
Tailwindcss::Upstream::NATIVE_PLATFORMS.each do |platform, filename|
  TAILWINDCSS_RAILS_GEMSPEC.dup.tap do |gemspec|
    exedir = File.join(gemspec.bindir, platform) # "exe/x86_64-linux"
    exepath = File.join(exedir, "tailwindcss") # "exe/x86_64-linux/tailwindcss"
    exepaths << exepath

    # modify a copy of the gemspec to include the native executable
    gemspec.platform = platform
    gemspec.files += [exepath, "LICENSE-DEPENDENCIES"]

    # create a package task
    gem_path = Gem::PackageTask.new(gemspec).define
    desc "Build the #{platform} gem"
    task "gem:#{platform}" => [gem_path]

    directory exedir
    file exepath => [exedir] do
      release_url = tailwindcss_download_url(filename)
      warn "Downloading #{exepath} from #{release_url} ..."

      # lazy, but fine for now.
      URI.open(release_url) do |remote|
        File.open(exepath, "wb") do |local|
          local.write(remote.read)
        end
      end
      FileUtils.chmod(0755, exepath, verbose: true)
    end
  end
end

desc "Download all tailwindcss binaries"
task "download" => exepaths

CLOBBER.add(exepaths.map { |p| File.dirname(p) })
