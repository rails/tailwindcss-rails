require "test_helper"
require "rails/generators/mailer/mailer_generator"
require "generators/tailwindcss/mailer/mailer_generator"

class Tailwindcss::Generators::MailerGeneratorTest < Rails::Generators::TestCase
  GENERATION_PATH = File.expand_path("../mailer_tmp", File.dirname(__FILE__))

  tests Rails::Generators::MailerGenerator
  destination GENERATION_PATH

  arguments %w(Notifications invoice)

   Minitest.after_run do
     FileUtils.rm_rf GENERATION_PATH
   end

  test "generates correct mailer view templates" do
    run_generator

    assert_file "app/views/notifications_mailer/invoice.html.erb" do |view|
      assert_match %r(app/views/notifications_mailer/invoice\.html\.erb), view
      assert_match(/\= @greeting/, view)
    end

    assert_file "app/views/notifications_mailer/invoice.text.erb" do |view|
      assert_match %r(app/views/notifications_mailer/invoice\.text\.erb), view
      assert_match(/\= @greeting/, view)
    end
  end
end

