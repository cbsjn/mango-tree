class CreateRoomTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :room_types do |t|
      t.integer :user_id
      t.integer :cloudbed_roomtype_id
      t.integer :property_id
      t.integer :source
      t.string :name
      t.string :code, :limit => 50
      t.text :description
      t.boolean :is_private
      t.integer :max_guests
      t.integer :max_adults
      t.integer :max_childrens
      t.integer :total_rooms
      t.integer :available_rooms

      t.timestamps
    end
  end
end
