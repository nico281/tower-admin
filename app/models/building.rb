class Building < ApplicationRecord
  acts_as_tenant(:company)

  belongs_to :company
  has_many :apartments, dependent: :destroy
  has_many :residents, through: :apartments

  validates :name, presence: true
end
