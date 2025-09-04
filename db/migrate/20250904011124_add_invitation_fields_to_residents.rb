class AddInvitationFieldsToResidents < ActiveRecord::Migration[8.0]
  def change
    add_column :residents, :invited_at, :datetime
    add_column :residents, :invitation_token, :string
    add_column :residents, :invitation_accepted_at, :datetime
    add_index :residents, :invitation_token, unique: true
  end
end
