class AddFieldsToResidents < ActiveRecord::Migration[8.0]
  def change
    add_column :residents, :first_name, :string
    add_column :residents, :last_name, :string
    add_column :residents, :phone, :string
    add_column :residents, :date_of_birth, :date
    add_column :residents, :emergency_contact, :string
    add_column :residents, :notes, :text
    remove_column :residents, :name, :string
  end
end
