class AddUserIdToSyncingError < ActiveRecord::Migration[5.0]
  def change
  	add_column :syncing_errors, :user_id, :integer
  end
end
