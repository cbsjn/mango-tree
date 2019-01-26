class RoomType < ApplicationRecord
	belongs_to :user

	def self.sync_room_types_from_cloudbeds(user)
    sleep 1
    response = HTTParty.get("#{CLOUDBEDS_BASE_API_URL}/getRoomTypes", {
                          headers: {
                            'Authorization' => "Bearer #{user.cb_access_token}"
                          }
                        })
    return response
  end


  def self.room_types(user, source)
    self.select(:id, :name).where("user_id = ? and source = ?", user.id, source)
  end
end
