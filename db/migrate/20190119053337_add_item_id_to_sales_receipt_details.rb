class AddItemIdToSalesReceiptDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :sales_receipt_details, :item_id, :integer
    add_column :sales_receipt_details, :tax_code_id, :integer
  end
end
