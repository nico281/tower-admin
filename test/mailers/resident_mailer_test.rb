require "test_helper"

class ResidentMailerTest < ActionMailer::TestCase
  test "invitation" do
    resident = residents(:invited_resident)
    mail = ResidentMailer.invitation(resident)
    assert_equal "Invitación para acceder al sistema de #{resident.company.name}", mail.subject
    assert_equal [ resident.email ], mail.to
    assert_match resident.first_name, mail.body.encoded
  end
end
