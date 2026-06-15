require "test_helper"
require "minitest/mock"

class Tailwindcss::CommandsTest < ActiveSupport::TestCase
  attr_accessor :executable

  def setup
    super
    @executable = Tailwindcss::Ruby.executable
  end

  test ".compile_command" do
    Rails.stub(:root, File) do # Rails.root won't work in this test suite
      actual = Tailwindcss::Commands.compile_command
      assert_kind_of(Array, actual)
      assert_equal(executable, actual.first)
      assert_includes(actual, "-i")
      assert_includes(actual, "-o")
    end
  end

  test ".compile_command debug flag" do
    Rails.stub(:root, File) do # Rails.root won't work in this test suite
      actual = Tailwindcss::Commands.compile_command
      assert_kind_of(Array, actual)
      assert_equal(executable, actual.first)
      assert_includes(actual, "--minify")

      actual = Tailwindcss::Commands.compile_command(debug: true)
      assert_kind_of(Array, actual)
      assert_equal(executable, actual.first)
      refute_includes(actual, "--minify")
    end
  end

  test ".compile_command debug environment variable" do
    begin
      Rails.stub(:root, File) do # Rails.root won't work in this test suite
        ENV["TAILWINDCSS_DEBUG"] = ""
        actual = Tailwindcss::Commands.compile_command
        assert_kind_of(Array, actual)
        assert_includes(actual, "--minify")

        actual = Tailwindcss::Commands.compile_command(debug: true)
        assert_kind_of(Array, actual)
        assert_includes(actual, "--minify")

        ENV["TAILWINDCSS_DEBUG"] = "any non-blank value"
        actual = Tailwindcss::Commands.compile_command
        assert_kind_of(Array, actual)
        refute_includes(actual, "--minify")

        actual = Tailwindcss::Commands.compile_command(debug: true)
        assert_kind_of(Array, actual)
        refute_includes(actual, "--minify")
      end
    ensure
      ENV.delete('TAILWINDCSS_DEBUG')
    end
  end

  test ".compile_command when Rails compression is on" do
    Rails.stub(:root, File) do # Rails.root won't work in this test suite
      Tailwindcss::Commands.stub(:rails_css_compressor?, true) do
        actual = Tailwindcss::Commands.compile_command
        assert_kind_of(Array, actual)
        refute_includes(actual, "--minify")
      end

      Tailwindcss::Commands.stub(:rails_css_compressor?, false) do
        actual = Tailwindcss::Commands.compile_command
        assert_kind_of(Array, actual)
        assert_includes(actual, "--minify")
      end
    end
  end

  test ".compile_command when postcss.config.js exists" do
    Dir.mktmpdir do |tmpdir|
      Rails.stub(:root, Pathname.new(tmpdir))  do # Rails.root won't work in this test suite
        actual = Tailwindcss::Commands.compile_command
        assert_kind_of(Array, actual)
        assert_equal(executable, actual.first)
        refute_includes(actual, "--postcss")

        config_file = Rails.root.join("postcss.config.js")
        FileUtils.touch(config_file)
        actual = Tailwindcss::Commands.compile_command
        assert_kind_of(Array, actual)
        assert_equal(executable, actual.first)
        assert_includes(actual, "--postcss")
        postcss_index = actual.index("--postcss")
        assert_equal(actual[postcss_index + 1], config_file.to_s)
      end
    end
  end

  test ".watch_command" do
    Rails.stub(:root, File) do # Rails.root won't work in this test suite
      actual = Tailwindcss::Commands.watch_command
      assert_kind_of(Array, actual)
      assert_equal(executable, actual.first)
      assert_includes(actual, "-w")
      refute_includes(actual, "-p")
      assert_includes(actual, "--minify")

      actual = Tailwindcss::Commands.watch_command(debug: true)
      assert_kind_of(Array, actual)
      assert_equal(executable, actual.first)
      assert_includes(actual, "-w")
      refute_includes(actual, "-p")
      refute_includes(actual, "--minify")

      actual = Tailwindcss::Commands.watch_command(always: true)
      assert_kind_of(Array, actual)
      assert_equal(executable, actual.first)
      assert_includes(actual, "-w")
      assert_includes(actual, "always")
    end
  end
end
