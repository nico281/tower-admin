class NotificationMailer < ApplicationMailer
  def new_notification(notification, recipient)
    @notification = notification
    @recipient = recipient
    @company = notification.company
    @building = recipient.building

    # Create tracking URL for marking as read
    @tracking_url = dashboard_url(
      subdomain: @company.subdomain,
      host: ActionMailer::Base.default_url_options[:host],
      port: ActionMailer::Base.default_url_options[:port],
      notification_id: notification.id
    )

    mail(
      to: @recipient.email,
      subject: "[#{@company.name}] #{@notification.title}"
    )
  end
end
