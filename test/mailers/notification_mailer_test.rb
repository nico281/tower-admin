require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  test "new_notification" do
    mail = NotificationMailer.new_notification
    assert_equal "New notification", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
