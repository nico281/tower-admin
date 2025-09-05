class Resident < ApplicationRecord
  acts_as_tenant(:company)

  belongs_to :apartment
  belongs_to :company
  has_many :payments, dependent: :destroy
  has_one :user, dependent: :destroy
  has_many :notification_recipients, dependent: :destroy
  has_many :notifications, through: :notification_recipients

  validates :email, presence: true, uniqueness: { scope: :company_id }
  validates :phone, format: { with: /\A[\d\s\+\-\(\)\.]+\z/, message: "must be a valid phone number" }, allow_blank: true
  validates :first_name, :last_name, length: { maximum: 50 }, allow_blank: true
  validates :invitation_token, uniqueness: true, allow_blank: true

  delegate :building, to: :apartment, allow_nil: true

  def full_name
    [ first_name, last_name ].compact.join(" ").presence
  end

  def display_name
    full_name || email
  end

  def invited?
    invited_at.present?
  end

  def invitation_pending?
    invited? && invitation_accepted_at.nil?
  end

  def invitation_accepted?
    invitation_accepted_at.present?
  end

  def generate_invitation_token!
    self.invitation_token = SecureRandom.urlsafe_base64(32)
    self.invited_at = Time.current
    save!
  end

  def unread_notifications_count
    notification_recipients.unread.count
  end
end
