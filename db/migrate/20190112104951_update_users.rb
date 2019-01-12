class UpdateUsers < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :qb_token, :text
  	add_column :users, :refresh_token, :text
  	add_column :users, :secret, :text
  	add_column :users, :realm_id, :string
  	add_column :users, :code, :string
  	add_column :users, :state, :string
  	add_column :users, :token_generated_at, :datetime
  end
end
