class CreateSyncingErrors < ActiveRecord::Migration[5.0]
  def change
    create_table :syncing_errors do |t|
    	t.string :error_type
    	t.text :description
    	t.string :status, default: :unresolved
      t.timestamps
    end
  end
end
