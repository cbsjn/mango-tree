class CreateTaxCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :tax_codes do |t|
      t.string :name, :limit => 200
      t.integer :user_id
      t.integer :qbo_id

      t.timestamps
    end
  end
end
