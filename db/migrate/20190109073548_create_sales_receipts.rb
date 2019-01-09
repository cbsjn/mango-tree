class CreateSalesReceipts < ActiveRecord::Migration[5.0]
  def change
    create_table :sales_receipts do |t|
    	t.integer :customer_id
    	t.string :email, :limit => 200
    	t.jsonb :billing_address
    	t.datetime :receipt_date
    	t.string :place_of_supply, :limit => 100
    	t.string :payment_method, :limit => 100
    	t.string :reference_no, :limit => 100
    	t.string :deposit_to, :limit => 100
    	t.string :message, :limit => 200
    	t.integer :total_qty
    	t.integer :total_amt
      t.timestamps
    end
  end
end
