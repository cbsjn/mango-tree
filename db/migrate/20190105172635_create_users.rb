class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :prefix, :limit => 6
      t.string :first_name, :limit => 200
      t.string :last_name, :limit => 200
      t.integer :age
      t.integer :sex
      t.string :mobile, :limit => 20
      t.string :email, :limit => 200
      t.string :password
      t.integer :role_id
      t.string :created_by
      t.string :updated_by
      t.timestamps null: false
    end
  end
end
