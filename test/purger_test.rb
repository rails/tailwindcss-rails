require "test_helper"

class Tailwindcss::PurgerTest < ActiveSupport::TestCase
  test "extract class names from erb string" do
    assert_equal %w[ div class max-w-7xl mx-auto my-1.5 px-4 sm:px-6 lg:px-8 sm:py-0.5 translate-x-1/2 ].sort,
      Tailwindcss::Purger.extract_class_names(%(<div class="max-w-7xl mx-auto my-1.5 px-4 sm:px-6 lg:px-8 sm:py-0.5 translate-x-1/2">))
  end

  test "extract class names from erb file" do
    assert_equal %w[ div class max-w-7xl mx-auto my-1.5 px-4 sm:px-6 lg:px-8 sm:py-0.5 translate-x-1/2 ].sort,
      Tailwindcss::Purger.extract_class_names_from(Pathname.new(__dir__).join("fixtures/simple.html.erb"))
  end

  test "extract class names from haml string" do
    assert_equal %w[ class max-w-7xl mx-auto my-1.5 px-4 sm:px-6 lg:px-8 sm:py-0.5 translate-x-1/2 ].sort,
      Tailwindcss::Purger.extract_class_names(%(.max-w-7xl.mx-auto.px-4.sm:px-6.lg:px-8{:class => "my-1.5 sm:py-0.5 translate-x-1/2"}))
  end

  test "extract class names from haml file" do
    assert_equal %w[ class max-w-7xl mx-auto my-1.5 px-4 sm:px-6 lg:px-8 sm:py-0.5 translate-x-1/2 ].sort,
      Tailwindcss::Purger.extract_class_names_from(Pathname.new(__dir__).join("fixtures/simple.html.haml"))
  end

  test "extract class names from slim string" do
    assert_equal %w[ class max-w-7xl mx-auto my-1.5 px-4 sm:px-6 lg:px-8 sm:py-0.5 translate-x-1/2 ].sort,
      Tailwindcss::Purger.extract_class_names(%(.max-w-7xl.mx-auto.px-4.sm:px-6.lg:px-8.translate-x-1/2 class="my-1.5 sm:py-0.5"))
  end

  test "extract class names from slim file" do
    assert_equal %w[ class max-w-7xl mx-auto my-1.5 px-4 sm:px-6 lg:px-8 sm:py-0.5 translate-x-1/2 ].sort,
      Tailwindcss::Purger.extract_class_names_from(Pathname.new(__dir__).join("fixtures/simple.html.slim"))
  end

  test "basic purge" do
    purged = purged_tailwind_from_erb_fixtures

    assert purged !~ /.mt-6 \{/

    assert purged =~ /.mt-5 \{/
    assert purged =~ /.sm\\:px-6 \{/
    assert purged =~ /.translate-x-1\\\/2 \{/
    assert purged =~ /.mt-10 \{/
    assert purged =~ /.my-1\\.5 \{/
    assert purged =~ /.sm\\:py-0\\.5 \{/
  end

  test "basic haml purge" do
    purged = purged_tailwind_from_haml_fixtures

    assert purged !~ /.mt-6 \{/

    assert purged =~ /.mt-5 \{/
    assert purged =~ /.sm\\:px-6 \{/
    assert purged =~ /.translate-x-1\\\/2 \{/
    assert purged =~ /.mt-10 \{/
    assert purged =~ /.my-1\\.5 \{/
    assert purged =~ /.sm\\:py-0\\.5 \{/
  end

  test "basic slim purge" do
    purged = purged_tailwind_from_slim_fixtures

    assert purged !~ /.mt-6 \{/

    assert purged =~ /.mt-5 \{/
    assert purged =~ /.sm\\:px-6 \{/
    assert purged =~ /.translate-x-1\\\/2 \{/
    assert purged =~ /.mt-10 \{/
    assert purged =~ /.my-1\\.5 \{/
    assert purged =~ /.sm\\:py-0\\.5 \{/
  end

  test "purge handles class names that begin with a number" do
    purged = purged_tailwind(keep_these_class_names: %w[32xl:container])

    assert_class_selector "32xl:container", purged
  end

  test "purge removes selectors that aren't on the same line as their block brace" do
    purged = purged_tailwind(keep_these_class_names: %w[aspect-w-9])

    assert_class_selector "aspect-w-9", purged
    assert_no_class_selector "aspect-w-1", purged
    assert purged !~ /,\s*@media/
  end

  test "purge removes empty blocks" do
    purged = purged_tailwind_from_erb_fixtures

    assert purged !~ /\{\s*\}/
  end

  test "purge removes top-level comments" do
    purged = purged_tailwind_from_erb_fixtures

    assert purged !~ /^#{Regexp.escape "/*"}/
  end

  test "purge shouldn't remove hover or focus classes" do
    purged = purged_tailwind_from_erb_fixtures
    assert purged =~ /.hover\\\:text-gray-500\:hover \{/
    assert purged =~ /.focus\\\:outline-none\:focus \{/
    assert purged =~ /.focus-within\\\:outline-black\:focus-within \{/
  end

  test "purge shouldn't remove placeholder selectors" do
    purged = purged_tailwind_from Pathname(__dir__).join("fixtures/placeholders.html.erb")

    assert purged =~ /.placeholder-transparent\:\:-moz-placeholder \{/
    assert purged =~ /.placeholder-transparent\:-ms-input-placeholder \{/
    assert purged =~ /.placeholder-transparent\:\:placeholder \{/
  end

  test "purge handles compound selectors" do
    purged = purged_tailwind(keep_these_class_names: %w[group group-hover:text-gray-500])

    assert_class_selector "group", purged
    assert_class_selector "group-hover:text-gray-500", purged
    assert_no_class_selector "group-hover:text-gray-100", purged
  end

  test "purge handles complex selector groups" do
    css = <<~CSS
      element.keep, element .keep, .red-herring.discard, .red-herring .discard {
        foo: bar;
      }
      element.discard, element .discard, .red-herring.discard, .red-herring .discard {
        baz: qux;
      }
    CSS

    expected = <<~CSS
      element.keep, element .keep {
        foo: bar;
      }
    CSS

    assert_equal expected, purged_css(css, keep_these_class_names: %w[keep red-herring])
  end

  test "purge handles nested blocks" do
    css = <<~CSS
      .keep {
        foo: bar;
        .discard {
          baz: qux;
        }
        .keep-nested {
          bar: foo;
        }
      }
    CSS

    expected = <<~CSS
      .keep {
        foo: bar;
        .keep-nested {
          bar: foo;
        }
      }
    CSS

    assert_equal expected, purged_css(css, keep_these_class_names: %w[keep keep-nested])
  end

  private
    def class_selector_pattern(class_name)
      /\.#{Regexp.escape Tailwindcss::Purger.escape_class_selector(class_name)}(?![-_a-z0-9\\])/
    end

    def assert_class_selector(class_name, css)
      assert css =~ class_selector_pattern(class_name)
    end

    def assert_no_class_selector(class_name, css)
      assert css !~ class_selector_pattern(class_name)
    end

    def purged_css(css, keep_these_class_names:)
      Tailwindcss::Purger.new(keep_these_class_names).purge(css)
    end

    def tailwind
      $tailwind ||= Pathname.new(__FILE__).join("../../app/assets/stylesheets/tailwind.css").read.freeze
    end

    def purged_tailwind(keep_these_class_names:)
      purged_css(tailwind, keep_these_class_names: keep_these_class_names)
    end

    def purged_tailwind_from_erb_fixtures
      $purged_tailwind_from_erb_fixtures ||= purged_tailwind_from Pathname(__dir__).glob("fixtures/*.html.erb")
    end

    def purged_tailwind_from_haml_fixtures
      $purged_tailwind_from_haml_fixtures ||= purged_tailwind_from Pathname(__dir__).glob("fixtures/*.html.haml")
    end

    def purged_tailwind_from_slim_fixtures
      $purged_tailwind_from_haml_fixtures ||= purged_tailwind_from Pathname(__dir__).glob("fixtures/*.html.slim")
    end

    def purged_tailwind_from files
      Tailwindcss::Purger.purge tailwind, keeping_class_names_from_files: files
    end
end
