class AddCloudbedsColumnToCustomers < ActiveRecord::Migration[5.0]
  def change
  	add_column :customers, :source, :integer
  end
end
