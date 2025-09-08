require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  test "new_notification" do
    notification = notifications(:one)
    recipient = users(:acme_resident_user)
    mail = NotificationMailer.new_notification(notification, recipient)
    assert_equal "[#{notification.company.name}] #{notification.title}", mail.subject
    assert_equal [ recipient.email ], mail.to
    assert_match notification.title, mail.body.encoded
  end
end
