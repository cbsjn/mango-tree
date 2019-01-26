class CreateMappings < ActiveRecord::Migration[5.0]
  def change
    create_table :mappings do |t|
      t.integer :cloudbed_id
      t.integer :user_id
      t.integer :qbo_id
      t.string :name

      t.timestamps
    end
  end
end
