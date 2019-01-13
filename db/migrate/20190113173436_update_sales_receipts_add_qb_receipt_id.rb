class UpdateSalesReceiptsAddQbReceiptId < ActiveRecord::Migration[5.0]
  def change
    add_column :sales_receipts, :qb_receipt_id, :integer
	end
end
