class AddMailchimpToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :mailchimp_api_key, :string
    add_column :users, :mailchimp_list_id, :string
  end
end
