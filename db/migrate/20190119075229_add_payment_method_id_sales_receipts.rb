class AddPaymentMethodIdSalesReceipts < ActiveRecord::Migration[5.0]
  def change
  	add_column :sales_receipts, :payment_method_id, :integer
  	add_column :sales_receipts, :deposit_to_id, :integer
  end
end
