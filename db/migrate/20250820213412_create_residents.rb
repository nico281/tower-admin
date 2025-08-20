class CreateResidents < ActiveRecord::Migration[8.0]
  def change
    create_table :residents do |t|
      t.string :name
      t.string :email
      t.references :apartment, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
