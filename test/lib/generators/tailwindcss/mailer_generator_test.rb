require "test_helper"
require "rails/generators/mailer/mailer_generator"
require "generators/tailwindcss/mailer/mailer_generator"

class Tailwindcss::Generators::MailerGeneratorTest < Rails::Generators::TestCase
  tests Tailwindcss::Generators::MailerGenerator
  destination TAILWINDCSS_TEST_APP_ROOT

  arguments %w(Notifications invoice)

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

    assert_file "app/views/layouts/mailer.text.erb" do |view|
      assert_match("<%= yield %>", view)
    end

    assert_file "app/views/layouts/mailer.html.erb" do |view|
      assert_match("<%= yield %>", view)
    end
  end

  test "generates correct mailer view templates with namespace" do
    run_generator ["admin/notifications", "invoice"]

    assert_file "app/views/admin/notifications_mailer/invoice.html.erb" do |view|
      assert_match %r(app/views/admin/notifications_mailer/invoice\.html\.erb), view
      assert_match(/\= @greeting/, view)
    end

    assert_file "app/views/admin/notifications_mailer/invoice.text.erb" do |view|
      assert_match %r(app/views/admin/notifications_mailer/invoice\.text\.erb), view
      assert_match(/\= @greeting/, view)
    end

    assert_file "app/views/layouts/admin/mailer.text.erb" do |view|
      assert_match("<%= yield %>", view)
    end

    assert_file "app/views/layouts/admin/mailer.html.erb" do |view|
      assert_match("<%= yield %>", view)
    end
  end
end

