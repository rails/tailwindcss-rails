module Tailwindcss
  # constants describing the upstream tailwindcss project
  module Upstream
    VERSION = "v3.0.22"

    # rubygems platform name => upstream release filename
    NATIVE_PLATFORMS = {
      "arm64-darwin" => "tailwindcss-macos-arm64",
      "x64-mingw32" => "tailwindcss-windows-x64.exe",
      "x86_64-darwin" => "tailwindcss-macos-x64",
      "x86_64-linux" => "tailwindcss-linux-x64",
      "aarch64-linux" => "tailwindcss-linux-arm64",
    }
  end
end
