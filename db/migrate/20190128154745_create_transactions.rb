class CreateTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :transactions do |t|
      t.integer :source
      t.integer :customer_id
      t.integer :user_id
      t.integer :qbo_id
      t.string :property_id
      t.string :reservation_id
      t.string :sub_reservation_id
      t.string :guest_id
      t.string :room_type_id
      t.string :room_type_name
      t.string :room_name
      t.string :guest_name
      t.text :description
      t.string :category
      t.integer :quantity
      t.decimal :amount
      t.string :currency
      t.string :username
      t.string :property_name
      t.datetime :guest_checkin
      t.datetime :guest_checkout
      t.string :transaction_type
      t.string :transaction_category
      t.string :transaction_id
      t.datetime :transaction_date

      t.timestamps
    end
  end
end
