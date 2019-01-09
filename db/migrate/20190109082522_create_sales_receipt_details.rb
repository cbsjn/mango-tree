class CreateSalesReceiptDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :sales_receipt_details do |t|
    	t.integer :sales_receipt_id
    	t.string :product_name, :limit => 200
    	t.string :product_description, :limit => 200
    	t.integer :qty
    	t.integer :rate
    	t.integer :amt
      t.timestamps
    end
  end
end
