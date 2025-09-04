# Preview all emails at http://localhost:3000/rails/mailers/resident_mailer
class ResidentMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/resident_mailer/invitation
  def invitation
    ResidentMailer.invitation
  end
end
