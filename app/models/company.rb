class Company < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :buildings, dependent: :destroy
  has_many :notifications, dependent: :destroy

  enum :plan, { basic: "basic", pro: "pro", entreprise: "entreprise" }

  validates :name, presence: true
  validates :plan, inclusion: { in: %w[basic pro entreprise] }
  validates :max_buildings, numericality: { greater_than_or_equal_to: 1 }
  validates :domain, presence: true, uniqueness: true
  validates :subdomain, presence: true, uniqueness: true

  def can_add_building?
    buildings.count < max_buildings
  end
end
