class NotificationRecipient < ApplicationRecord
  belongs_to :notification
  belongs_to :resident

  scope :read, -> { where.not(read_at: nil) }
  scope :unread, -> { where(read_at: nil) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    return if read?

    update!(read_at: Time.current)

    # Update the notification read count
    notification.increment!(:read_count)
  end

  def unread?
    !read?
  end
end
