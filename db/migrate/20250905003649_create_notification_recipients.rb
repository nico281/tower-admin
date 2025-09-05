class CreateNotificationRecipients < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_recipients do |t|
      t.references :notification, null: false, foreign_key: true
      t.references :resident, null: false, foreign_key: true
      t.datetime :read_at

      t.timestamps
    end
  end
end
