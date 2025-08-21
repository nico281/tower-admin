class Payment < ApplicationRecord
  belongs_to :resident
  belongs_to :building
  belongs_to :company

  enum status: { pending: 0, paid: 1, failed: 2 }

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end
