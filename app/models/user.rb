class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  acts_as_tenant(:company)
  belongs_to :company, optional: true
  enum :role, [ :admin, :manager, :accountant ]
  def super_admin?
    super_admin
  end
end
