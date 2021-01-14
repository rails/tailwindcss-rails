require "test_helper"

class Tailwindcss::PurgerTest < ActiveSupport::TestCase
  test "extract class names from string" do
    assert_equal %w[ div class max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 translate-x-1/2 ].sort,
      Tailwindcss::Purger.extract_class_names(%(<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 translate-x-1/2">))
  end

  test "extract class names from files" do
    assert_equal %w[ div class max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 translate-x-1/2 ].sort,
      Tailwindcss::Purger.extract_class_names_from(Pathname.new(__dir__).join("fixtures/simple.html.erb"))
  end

  test "basic purge" do
    purged = Tailwindcss::Purger.purge \
      Pathname.new(__FILE__).join("../../app/assets/stylesheets/tailwind.css").read, 
      keeping_class_names_from_files: Pathname(__dir__).glob("fixtures/*.html.erb")
  
    assert purged !~ /.mt-6 \{/
  
    assert purged =~ /.mt-5 \{/
    assert purged =~ /.sm\\:px-6 \{/
    assert purged =~ /.translate-x-1\\\/2 \{/
    assert purged =~ /.mt-10 \{/
  end
end
