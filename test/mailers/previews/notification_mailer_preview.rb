# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/new_notification
  def new_notification
    NotificationMailer.new_notification
  end
end
