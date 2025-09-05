class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.string :title
      t.text :message
      t.integer :notification_type
      t.integer :priority
      t.string :target_type
      t.integer :target_id
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :company, null: false, foreign_key: true
      t.datetime :sent_at
      t.integer :read_count
      t.integer :total_recipients

      t.timestamps
    end
  end
end
