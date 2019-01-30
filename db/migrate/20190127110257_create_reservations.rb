class CreateReservations < ActiveRecord::Migration[5.0]
  def change
    create_table :reservations do |t|
      t.integer :customer_id
      t.integer :user_id
      t.string :reservation_id
      t.string :guest_id
      t.string :status
      t.datetime :checkout_date

      t.timestamps
    end
  end
end
