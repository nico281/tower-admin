class Payment < ApplicationRecord
  belongs_to :resident
  belongs_to :building
  belongs_to :company
end
