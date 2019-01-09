class CreateCustomers < ActiveRecord::Migration[5.0]
  def change
    create_table :customers do |t|
    	t.string :title, :limit => 50
    	t.string :first_name, :limit => 200
    	t.string :middle_name, :limit => 200
    	t.string :last_name, :limit => 200
			t.string :suffix, :limit => 50
			t.string :display_name, :limit => 200
			t.string :email, :limit => 200
			t.string :company_name, :limit => 200
			t.string :phone, :limit => 20
			t.string :mobile, :limit => 20
			t.string :notes, :limit => 255
			t.string :address1, :limit => 200
			t.string :city, :limit => 50
			t.string :state, :limit => 50
			t.string :country, :limit => 50
			t.string :postal_code, :limit => 6
      t.boolean :status, :default => true
      t.timestamps
    end
  end
end
