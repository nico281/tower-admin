class NotificationService
  def self.send_to_building(building, notification_params, sender)
    new.send_to_building(building, notification_params, sender)
  end

  def self.send_to_apartment(apartment, notification_params, sender)
    new.send_to_apartment(apartment, notification_params, sender)
  end

  def self.send_to_all_buildings(company, notification_params, sender)
    new.send_to_all_buildings(company, notification_params, sender)
  end

  def send_to_building(building, notification_params, sender)
    # Create notification
    notification = create_notification(building, notification_params, sender)

    # Get all residents in the building
    residents = building.residents.joins(:user).where.not(users: { id: nil })

    # Create recipient records
    create_recipients(notification, residents)

    # Send emails
    deliver_notifications(notification)

    notification
  end

  def send_to_apartment(apartment, notification_params, sender)
    # Create notification
    notification = create_notification(apartment, notification_params, sender)

    # Get all residents in the apartment
    residents = apartment.residents.joins(:user).where.not(users: { id: nil })

    # Create recipient records
    create_recipients(notification, residents)

    # Send emails
    deliver_notifications(notification)

    notification
  end

  def send_to_all_buildings(company, notification_params, sender)
    # Create notification
    notification = create_notification(company, notification_params, sender)

    # Get all residents in all buildings of the company
    residents = Resident.joins(:user, apartment: :building)
                       .where(company: company)
                       .where.not(users: { id: nil })

    # Create recipient records
    create_recipients(notification, residents)

    # Send emails
    deliver_notifications(notification)

    notification
  end

  private

  def create_notification(target, params, sender)
    Notification.create!(
      title: params[:title],
      message: params[:message],
      notification_type: params[:notification_type],
      priority: params[:priority],
      target: target,
      sender: sender,
      company: ActsAsTenant.current_tenant
    )
  end

  def create_recipients(notification, residents)
    recipients_data = residents.map do |resident|
      {
        notification_id: notification.id,
        resident_id: resident.id,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    NotificationRecipient.insert_all(recipients_data) if recipients_data.any?
  end

  def deliver_notifications(notification)
    notification.recipients.each do |recipient|
      NotificationMailer.new_notification(notification, recipient).deliver_later
    end

    notification.mark_as_sent!
  end
end
