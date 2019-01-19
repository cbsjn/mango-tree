class AddPaymentMethodIdToCustomers < ActiveRecord::Migration[5.0]
  def change
  	add_column :customers, :payment_method_id, :integer
  end
end
