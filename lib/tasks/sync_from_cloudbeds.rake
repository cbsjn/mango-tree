namespace :sync_from_cloudbeds  do
  desc "Refresh AccessToken For All Users as it is valid for 3600 seconds only"
  task :sync_access_tokens => :environment do
    User.cloudbed_users.each do |u|
    	next unless u.cb_refresh_token.present?
    	token_generated_before = Time.now.localtime.to_i - u.cb_token_generated_at.localtime.to_i
    	if token_generated_before > TOKEN_VALID_TIME_IN_SECS
	    	begin
		    	response = User.sync_access_tokens_from_cloudbeds(u)
		    	access_token = response['access_token']
		    	refresh_token = response['refresh_token']
		    	puts "Old AccessToken : #{u.cb_access_token} --- New Access Token : #{access_token}"
		    	puts "Old RefreshToken : #{u.cb_refresh_token} ---- New RefreshToken : #{refresh_token}"
		    	if access_token.present? && refresh_token.present?
			    	u.update_attributes(cb_refresh_token: refresh_token, cb_access_token: access_token, cb_token_generated_at: Time.now)
			    	puts "Synced Access Token For user : #{u.first_name} with Id : #{u.id}"
			    else
			    	puts "Not Updating User as Blank Tokens Received"
			    end
		    rescue Exception => ex
		    	puts "Exception : #{ex.inspect}"
		    end
		  else
		  	puts "Token is valid till #{TOKEN_VALID_TIME_IN_SECS} seconds and #{TOKEN_VALID_TIME_IN_SECS - token_generated_before} seconds are still left"
	  	end
    end
  end


  desc "Sync PaymentMethods From Cloudbeds"
  task :sync_payment_methods => :environment do
    User.cloudbed_users.each do |u|
    	begin
	    	result = PaymentMethod.sync_payment_methods_from_cloudbeds(u)
	      source = PaymentMethod::SOURCE['Cloudbeds']
	      if result['data'].present?
		    	result['data']['methods'].each do |obj|
		    		code = obj["method"]
		    		name = obj["name"]
		    		payment_method = PaymentMethod.find_or_create_by(source: source, code: code, user_id: u.id)
		    		payment_method.name = name
		    		payment_method.user_id = u.id
		    		payment_method.source = source if payment_method.new_record?
		    		payment_method.save!
		    		puts "Synced PaymentMethod : #{name}"
		    	end
	    	else
		    	puts "Status : #{result['error']}"
		    	puts "Message : #{result['message']}"
		    end
	    rescue Exception => ex
	    	puts "Exception : #{ex.inspect}"
	    end
    end
  end

  desc "Sync ItemCategory From Cloudbeds"
  task :sync_item_categories => :environment do
    User.cloudbed_users.each do |u|
    	begin
	    	result = Item.sync_item_categories_from_cloudbeds(u)
	    	source = Item::SOURCE['Cloudbeds']
	    	if result['data'].present?
		    	result['data'].each do |obj|
		    		id = obj["categoryID"]
		    		code = obj["categoryCode"]
		    		name = obj["categoryName"]
		    		item = Item.find_or_create_by(source: source, qbo_id: id, user_id: u.id)
		    		item.name = name
		    		item.code = code
		    		item.user_id = u.id
		    		item.source = source if item.new_record?
		    		item.save!
		    		puts "Synced ItemCategory : #{name}"
		    	end
		    else
		    	puts "Status : #{result['error']}"
		    	puts "Message : #{result['message']}"
		    end
	    rescue Exception => ex
	    	puts "Exception : #{ex.inspect}"
	    end
    end
  end

  desc "Sync RoomTypes From Cloudbeds"
  task :sync_room_types => :environment do
    User.cloudbed_users.each do |u|
    	begin
	    	result = RoomType.sync_room_types_from_cloudbeds(u)
	    	source = Item::SOURCE['Cloudbeds']
	    	if result['data'].present?
		    	result['data'].each do |obj|
		    		id = obj["roomTypeID"]
		    		code = obj["roomTypeNameShort"]
		    		name = obj["roomTypeName"]
		    		property_id = obj["propertyID"]
		    		description = obj["roomTypeDescription"]
		    		is_private = obj["isPrivate"]
		    		max_guests = obj["maxGuests"]
		    		max_adults = obj["adultsIncluded"]
		    		max_childrens = obj["childrenIncluded"]
		    		total_rooms = obj["roomTypeUnits"]
		    		available_rooms = obj["roomsAvailable"]

		    		room_type = RoomType.find_or_create_by(source: source, cloudbed_roomtype_id: id, user_id: u.id)
		    		room_type.name = name
		    		room_type.code = code
		    		room_type.property_id = property_id	
						room_type.description = description
						room_type.is_private = is_private
						room_type.max_guests = 
						room_type.max_adults = max_adults
						room_type.max_childrens = max_childrens
						room_type.total_rooms = total_rooms
						room_type.available_rooms = available_rooms

		    		room_type.user_id = u.id
		    		room_type.source = source if room_type.new_record?
		    		room_type.save!
		    		puts "Synced RoomType : #{name}"
		    	end
		    else
		    	puts "Status : #{result['error']}"
		    	puts "Message : #{result['message']}"
		    end
	    rescue Exception => ex
	    	puts "Exception : #{ex.inspect}"
	    end
    end
  end
end