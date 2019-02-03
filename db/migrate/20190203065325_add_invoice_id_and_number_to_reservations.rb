class AddInvoiceIdAndNumberToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :qbo_invoice_id, :string
    add_column :reservations, :qbo_invoice_number, :string
  end
end
