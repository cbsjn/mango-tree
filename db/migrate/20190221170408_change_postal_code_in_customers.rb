class ChangePostalCodeInCustomers < ActiveRecord::Migration[5.0]
  def change
  	change_column :customers, :postal_code, :string, :limit => 100
  end
end
