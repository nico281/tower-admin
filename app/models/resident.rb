class Resident < ApplicationRecord
  acts_as_tenant(:company)

  belongs_to :apartment
  belongs_to :company
  has_many :payments, dependent: :destroy

  validates :email, presence: true
end
