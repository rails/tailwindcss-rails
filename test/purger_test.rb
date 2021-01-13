require "test_helper"

class Tailwindcss::PurgerTest < ActiveSupport::TestCase
  test "extract class names" do
    assert_equal %w[ div class max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 ].sort,
      %(<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">).scan(Tailwindcss::Purger::CLASS_NAME_PATTERN).flatten.sort
  end

  test "basic purge" do
    purger = Tailwindcss::Purger.new(paths_with_css_class_names: [ "app/views/**/*.html*", "app/helpers/**/*.rb" ])
    purged = purger.purge(Pathname.new(__FILE__).join("../../app/assets/stylesheets/tailwind.css").read)

    assert_not purged =~ /.mt-6 \{/
    assert purged =~ /.mt-10 \{/
  end
end
