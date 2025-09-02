class RenameStatusToPaymentStatusInPayments < ActiveRecord::Migration[8.0]
  def change
    rename_column :payments, :status, :payment_status
  end
end
