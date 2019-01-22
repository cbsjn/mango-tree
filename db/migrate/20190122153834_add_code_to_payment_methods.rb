class AddCodeToPaymentMethods < ActiveRecord::Migration[5.0]
  def change
  	add_column :payment_methods, :code, :string
  end
end
