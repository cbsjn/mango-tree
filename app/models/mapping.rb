class Mapping < ApplicationRecord
	belongs_to :user

	validates :cloudbed_id, :qbo_id, :name, presence: true
	validates :name, uniqueness: { scope: [:cloudbed_id, :qbo_id, :user_id], message: " : This Mapping Combination Already Exists." }

	MAPPING_TYPES = ['PaymentMethod', 'RoomType', 'ItemCategory']

	def get_display_name(mapping_name, mapping_id, source)
		if mapping_name == MAPPING_TYPES[0]
			PaymentMethod.find(mapping_id).name
		elsif mapping_name == MAPPING_TYPES[1]
			if source == 'QuickBook'
				Item.find(mapping_id).name
			elsif source == 'Cloudbed'
				RoomType.find(mapping_id).name
			end
		elsif mapping_name == MAPPING_TYPES[2]
			Item.find(mapping_id).name
		end	
	end
end
