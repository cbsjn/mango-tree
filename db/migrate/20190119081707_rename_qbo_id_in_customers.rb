class RenameQboIdInCustomers < ActiveRecord::Migration[5.0]
  def change
    rename_column :customers, :qb_cust_id, :qbo_id
  end
end
