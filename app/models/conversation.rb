class Conversation < ApplicationRecord
  acts_as_tenant(:company)

  belongs_to :company
  belongs_to :resident
  has_many :messages, dependent: :destroy

  validates :resident_id, uniqueness: { scope: :company_id }

  def participant?(user)
    return false unless user
    # Company user in same tenant or the resident user linked to this resident
    (user.company_id.present? && user.company_id == company_id) || (user.resident_id.present? && user.resident_id == resident_id)
  end
end
