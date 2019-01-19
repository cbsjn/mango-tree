class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
    	t.integer :qbo_id
    	t.integer :user_id
    	t.string :name, :limit => 200
      t.timestamps
    end
  end
end
