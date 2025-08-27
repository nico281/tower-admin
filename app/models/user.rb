class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  acts_as_tenant(:company, optional: true)
  belongs_to :company, optional: true
  enum :role, [ :super_admin, :admin, :manager, :accountant, :resident ]

  # Validation to ensure super_admin users don't have a company
  validate :super_admin_cannot_have_company

  def super_admin?
    super_admin
  end

  private

  def super_admin_cannot_have_company
    if super_admin? && company_id.present?
      errors.add(:company_id, "cannot be selected for super admin users")
    end
  end
end
