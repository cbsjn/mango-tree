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
		    		if payment_method.save
		    			puts "Synced PaymentMethod : #{name}"
		    		else
			    		puts "Validation Failed : #{payment_method.errors.full_messages}"
			    	end
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
		    		if item.save
		    			puts "Synced ItemCategory : #{name}"
		    		else
			    		puts "Validation Failed : #{item.errors.full_messages}"
			    	end
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
		    		if room_type.save
		    			puts "Synced RoomType : #{name}"
		    		else
			    		puts "Validation Failed : #{room_type.errors.full_messages}"
			    	end
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

  desc "Sync CheckedOutGuests From Cloudbeds"
  task :sync_checked_out_guests => :environment do
    User.cloudbed_users.each do |u|
    	begin
    		checkout_date = (Time.now - 1.day).strftime('%Y-%m-%d')
	    	result = Customer.sync_checked_out_guests(u, checkout_date)
	    	source = Item::SOURCE['Cloudbeds']
	    	if result['data'].present?
		    	result['data'].each do |obj|
		    		id = obj["guestID"]
		    		reservation_id = obj['reservationID']

		    		customer = Customer.find_or_create_by(source: source, cloudbed_guest_id: id, user_id: u.id)
		    		customer.first_name = obj['guestFirstName']
		    		customer.last_name = obj['guestLastName']
		    		customer.email = obj['guestEmail'].strip
		    		user_name = customer.email.split('@').first
		    		display_name = user_name.present? ? "#{user_name}-#{id}" : "#{first_name}-#{id}"
		    		customer.display_name = display_name.strip
		    		customer.phone = obj['guestPhone']
		    		customer.mobile = obj['guestCellPhone'] || phone
		    		customer.company_name = obj['companyName'].present? ? obj['companyName'] : display_name
		    		customer.notes = obj['guestNotes'].present? ? obj['guestNotes'].join(', ') : 'N/A'
		    		address1 = (obj['guestAddress1'] + ', ' + obj['guestAddress2'])
		    		customer.address1 = address1.present? ? address1 : 'N/A'
		    		customer.city = obj['guestCity'].present? ? obj['guestCity'] : 'N/A'
		    		customer.state = obj['guestState'].present? ? obj['guestState'] : 'N/A'
		    		customer.country = obj['guestCountry'].present? ? obj['guestCountry'] : 'N/A'
		    		customer.postal_code = obj['guestZip'].present? ? obj['guestZip'] : 'N/A'

		    		customer.user_id = u.id
		    		customer.source = source if customer.new_record?

		    		## create reservation details
		    		reservation = Reservation.where(user_id: customer.user_id, reservation_id: reservation_id).first
		    		unless reservation.present?
			    		customer.reservations.build(
			    																user_id: customer.user_id,
			    																reservation_id: reservation_id,
			    																guest_id: customer.cloudbed_guest_id,
			    																status: obj['status'],
			    																checkout_date: checkout_date
																	    	)
		    		end


		    		if customer.save
		    			puts "Synced Guest : #{display_name}"
			    	else
			    		puts "Validation Failed : #{customer.errors.full_messages}"
			    	end
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

  desc "Sync Transactions From Cloudbeds"
  task :sync_transactions => :environment do
    User.cloudbed_users.each do |u|
    	source = Item::SOURCE['Cloudbeds']
    	u.customers.each do |customer|
    		customer.reservations.each do |reservation|
    			next if reservation.transactions.present?
    			reservation_id = reservation.id	
		    	begin
			    	result = Transaction.sync_transactions_from_cloudbeds(u, reservation.reservation_id)
			    	if result['data'].present?
				    	result['data'].each do |obj|
				    		room_type = RoomType.where(cloudbed_roomtype_id: obj['roomTypeID']).first

				    		transaction_id = obj["transactionID"]
				    		transaction = Transaction.find_or_create_by(source: source, user_id: u.id, customer_id: customer.id, transaction_id: transaction_id, reservation_id: reservation_id)
								unless transaction.qbo_id.present?
									transaction.property_id = obj['propertyID']
									transaction.guest_id = obj['guestID']
									transaction.property_name = obj['propertyName']
									transaction.transaction_date = obj['transactionDateTime']
									transaction.guest_checkin = obj['guestCheckIn']
									transaction.guest_checkout = obj['guestCheckOut']
									transaction.room_type_id = room_type&.id
									transaction.room_type_name = obj['roomTypeName']
									transaction.room_name = obj['roomName']
									transaction.guest_name = obj['guestName']
									transaction.description = obj['description']
									transaction.category = obj['category']
									transaction.quantity = obj['quantity']
									transaction.amount = obj['amount']
									transaction.currency = obj['currency']
									transaction.username = obj['userName']
									transaction.transaction_type = obj['transactionType']
									transaction.transaction_category = obj['transactionCategory']
					    		transaction.sub_reservation_id = obj['subReservationID']

						    	if transaction.save
						    		puts "Synced Transaction : #{transaction_id}"
					    		else
						    		puts "Validation Failed : #{transaction.errors.full_messages}"
						    	end
					    	else
					    		puts "Transaction# #{transaction_id} is already synced on Quickbook with ID : #{transaction.qbo_id}"
					    	end
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
  end

end