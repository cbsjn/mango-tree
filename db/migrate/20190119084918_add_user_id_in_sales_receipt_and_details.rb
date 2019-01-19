class AddUserIdInSalesReceiptAndDetails < ActiveRecord::Migration[5.0]
  def change
  	add_column :sales_receipts, :user_id, :integer
  	add_column :sales_receipt_details, :user_id, :integer
  end
end
