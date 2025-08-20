class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :plan
      t.integer :max_buildings

      t.timestamps
    end
  end
end
