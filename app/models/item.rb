class Item < ApplicationRecord
	belongs_to :user
	has_many :sales_receipt_details
  SOURCE = {'Quickbook' => 1, 'Cloudbeds' => 2, 'Website' => 3}

  def self.synced(user)
    self.where("user_id = ? and qbo_id IS NOT NULL ", user.id).order(:name)
  end

	def self.sync_items_from_qbo(token, company_id)
    result = HTTParty.post("#{BASE_API_URL}/company/#{company_id}/query?query=select Name from Item", 
    :headers => { 'content-type' => 'application/json',
                  'Content-Type' => 'application/json',
                  Authorization: "Bearer #{token}" } 
    )
    result = Hash.from_xml(result.body)
    result
	end

  def self.sync_item_categories_from_cloudbeds(user)
    sleep 1
    response = HTTParty.get("#{CLOUDBEDS_BASE_API_URL}/getItemCategories", {
                          headers: {
                            'Authorization' => "Bearer #{user.cb_access_token}"
                          }
                        })
    return response
  end

  def self.items(user, source)
    self.select(:id, :name).where("user_id = ? and source = ?", user.id, source)
  end

  def self.get_qbo_mapped_item(user_id, transaction)
    categories = ['Items and Services', 'Fees', 'Poster', 'Room Revenue', 'Taxes']
    category = transaction.category
    if category == 'Room Revenue'
      room_type_id = transaction.room_type_id
      item_id = Mapping.where(user_id: user_id, cloudbed_id: room_type_id, name: 'RoomType').first&.qbo_id
      Item.find(item_id).qbo_id
    else
      1
    end
  end
end
