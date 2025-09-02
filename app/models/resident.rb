class Resident < ApplicationRecord
  acts_as_tenant(:company)

  belongs_to :apartment
  belongs_to :company
  has_many :payments, dependent: :destroy

  validates :email, presence: true, uniqueness: { scope: :company_id }
  validates :phone, format: { with: /\A[\d\s\+\-\(\)\.]+\z/, message: "must be a valid phone number" }, allow_blank: true
  validates :first_name, :last_name, length: { maximum: 50 }, allow_blank: true

  delegate :building, to: :apartment, allow_nil: true

  def full_name
    [first_name, last_name].compact.join(' ').presence
  end

  def display_name
    full_name || email
  end
end
