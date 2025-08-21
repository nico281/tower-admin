class Apartment < ApplicationRecord
  acts_as_tenant(:company)

  belongs_to :building
  belongs_to :company
  has_many :residents, dependent: :destroy
end
