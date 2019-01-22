class AddSourceToPaymentMethodsAndItems < ActiveRecord::Migration[5.0]
  def change
  	add_column :payment_methods, :source, :integer
  	add_column :items, :source, :integer
  end
end
