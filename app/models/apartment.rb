class Apartment < ApplicationRecord
  belongs_to :building
  belongs_to :company
end
