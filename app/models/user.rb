class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  acts_as_tenant(:company, optional: true)
  belongs_to :company, optional: true
  enum :role, [ :super_admin, :admin, :manager, :accountant, :resident ]

  def super_admin?
    super_admin
  end
end
