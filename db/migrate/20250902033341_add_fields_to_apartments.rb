class AddFieldsToApartments < ActiveRecord::Migration[8.0]
  def change
    add_column :apartments, :floor, :integer
    add_column :apartments, :bedrooms, :integer
    add_column :apartments, :bathrooms, :integer
    add_column :apartments, :size, :decimal
    add_column :apartments, :description, :text
  end
end
