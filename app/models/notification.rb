class Notification < ApplicationRecord
  acts_as_tenant(:company)

  belongs_to :sender, class_name: "User"
  belongs_to :company
  belongs_to :target, polymorphic: true

  has_many :notification_recipients, dependent: :destroy
  has_many :recipients, through: :notification_recipients, source: :resident

  enum :notification_type, {
    general: 0,
    maintenance: 1,
    payment: 2,
    emergency: 3,
    event: 4
  }

  enum :priority, {
    low: 0,
    normal: 1,
    high: 2,
    urgent: 3
  }

  validates :title, presence: true, length: { maximum: 255 }
  validates :message, presence: true
  validates :notification_type, presence: true
  validates :priority, presence: true

  scope :sent, -> { where.not(sent_at: nil) }
  scope :unsent, -> { where(sent_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def sent?
    sent_at.present?
  end

  def mark_as_sent!
    update!(sent_at: Time.current, total_recipients: recipients.count)
  end

  def read_percentage
    return 0 if total_recipients.zero?
    ((read_count || 0).to_f / total_recipients * 100).round(1)
  end

  def unread_count
    (total_recipients || 0) - (read_count || 0)
  end

  def target_description
    case target_type
    when "Building"
      "Building: #{target.name}"
    when "Apartment"
      "Apartment: #{target.building.name} - #{target.number || target.id}"
    when "Company"
      "All Buildings"
    else
      "Unknown target"
    end
  end
end
