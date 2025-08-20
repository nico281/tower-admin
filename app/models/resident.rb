class Resident < ApplicationRecord
  belongs_to :apartment
  belongs_to :company
end
