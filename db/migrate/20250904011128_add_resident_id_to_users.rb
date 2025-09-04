class AddResidentIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :resident, null: true, foreign_key: true
  end
end
