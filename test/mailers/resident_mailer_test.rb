require "test_helper"

class ResidentMailerTest < ActionMailer::TestCase
  test "invitation" do
    mail = ResidentMailer.invitation
    assert_equal "Invitation", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
