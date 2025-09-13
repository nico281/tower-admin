class AddMissingTenancyToExistingModels < ActiveRecord::Migration[8.0]
  def change
    # Ensure ActsAsTenant can scope messages/conversations properly via foreign keys
    add_foreign_key :messages, :companies unless foreign_key_exists?(:messages, :companies)
    add_foreign_key :conversations, :companies unless foreign_key_exists?(:conversations, :companies)
  end
end
