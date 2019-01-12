class UpdateCustomersAddQbCustId < ActiveRecord::Migration[5.0]
  def change
  	add_column :customers, :qb_cust_id, :integer
  end
end
