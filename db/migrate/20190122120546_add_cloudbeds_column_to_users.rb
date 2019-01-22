class AddCloudbedsColumnToUsers < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :cb_access_token, :string
  	add_column :users, :cb_refresh_token, :string
  	add_column :users, :cb_token_generated_at, :datetime, default: Time.now
  end
end
