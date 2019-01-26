module ApplicationHelper
	def payment_methods(source)
		payment_method_hash = {}
		PaymentMethod.payment_method(current_user, source).each do |payment_method|
			payment_method_hash[payment_method.name] = payment_method.id
		end
		payment_method_hash
	end

	def room_types(source)
		room_type_hash = {}
		RoomType.room_types(current_user, source).each do |room_type|
			room_type_hash[room_type.name] = room_type.id
		end
		room_type_hash
	end

	def items(source)
		items_hash = {}
		Item.items(current_user, source).each do |item|
			items_hash[item.name] = item.id
		end
		items_hash
	end
end
