require "test_helper"

class Tailwindcss::PurgerTest < ActiveSupport::TestCase
  test "basic purge" do
    purger = Tailwindcss::Purger.new(
      stylesheet_path: Pathname.new(__FILE__).join("../../app/assets/stylesheets/tailwindcss/tailwind.css"),
      paths_with_css_class_names: [ "app/views/**/*.html*", "app/helpers/**/*.rb" ]
    )

    assert_not purger.purge =~ /.mt-6 \{/
    assert purger.purge =~ /.mt-10 \{/
  end
end
