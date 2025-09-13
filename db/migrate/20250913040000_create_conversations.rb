class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :company, null: false, foreign_key: true
      t.references :resident, null: false, foreign_key: true
      t.timestamps
    end

    add_index :conversations, [ :company_id, :resident_id ], unique: true
  end
end
