class CreateDeposits < ActiveRecord::Migration[5.0]
  def change
    create_table :deposits do |t|
      t.string :name
      t.integer :user_id
      t.integer :qbo_id

      t.timestamps
    end
  end
end
