class AddGuestIdToCustomers < ActiveRecord::Migration[5.0]
  def change
  	add_column :customers, :cloudbed_guest_id, :string
  end
end
