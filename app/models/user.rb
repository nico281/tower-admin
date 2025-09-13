class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  acts_as_tenant(:company, optional: true)
  belongs_to :company, optional: true
  belongs_to :resident, optional: true
  has_many :sent_notifications, class_name: "Notification", foreign_key: "sender_id", dependent: :nullify
  enum :role, [ :super_admin, :admin, :manager, :accountant, :resident ]

  # Validation to ensure super_admin users don't have a company
  validate :super_admin_cannot_have_company
  # Validation to ensure resident users have a linked resident record
  validate :resident_user_must_have_resident_record

  def super_admin?
    role == "super_admin"
  end

  def display_name
    if resident.present?
      resident.display_name
    else
      email.split("@").first
    end
  end

  private

  def super_admin_cannot_have_company
    if super_admin? && company_id.present?
      errors.add(:company_id, "cannot be selected for super admin users")
    end
  end

  def resident_user_must_have_resident_record
    if role == "resident" && resident_id.blank?
      errors.add(:resident, "must be linked for resident users")
    end
  end
end
