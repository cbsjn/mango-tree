namespace :sync_from_qbo  do
	# Schedule every 50 mins
	desc "Sync Tokens From QBO"
  task :sync_tokens => :environment do
    User.all.each do |u|
    	begin
		 		url = URI('https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer')
		    queryparams = {
		      'grant_type' => 'refresh_token',
		      'refresh_token' => u.refresh_token.to_s
		    }
		    header_value = "Basic " + Base64.strict_encode64(OAUTH_CONSUMER_KEY.to_s + ":" + OAUTH_CONSUMER_SECRET.to_s)
		    headers = {
		      'Content-type' => "application/x-www-form-urlencoded",
		      'Accept' => "application/json",
		      'Authorization' => header_value
		    }
		    http = Net::HTTP.new(url.host, url.port)
		    http.use_ssl = true
		    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		    req = Net::HTTP::Post.new(url, headers)
		    req.set_form_data(queryparams, "&")
		    response = http.request(req)
				hash_response = JSON.parse(response.body)
				if hash_response['access_token'].present? && hash_response['refresh_token'].present?
					u.update_attributes(qb_token: hash_response['access_token'], refresh_token: hash_response['refresh_token'], token_generated_at: Time.now)
					puts "Token Synced Successfully for User : #{u.email}"
				else
					puts "Token Not Received from QBO for User : #{u.email}"
					SyncingError.create(user_id: u.id, error_type: SyncingError::SYNC_TOKENS_FROM_QBO, description: "Token Not Received from QBO for User : #{u.email}")
				end
	    rescue Exception => ex
	    	puts "Exception : #{ex.inspect}"
	    	SyncingError.create(user_id: u.id, error_type: SyncingError::SYNC_TOKENS_FROM_QBO, description: ex.message)
	    end
    end
  end

  desc "Sync Items From QBO"
  task :sync_items => :environment do
    User.all.each do |u|
    	begin
    		source = Item::SOURCE['Quickbook']
	    	access_token = OAuth2::AccessToken.new($qb_consumer, u.qb_token, {refresh_token: u.refresh_token})
	    	new_access_token = access_token.refresh!
	    	result = Item.sync_items_from_qbo(new_access_token.token, u.realm_id)
	    	result['IntuitResponse']['QueryResponse']['Item'].each do |qbo_item|
	    		qbo_item_id = qbo_item["Id"]
	    		qbo_item_name = qbo_item["Name"]
	    		item = Item.find_or_create_by(qbo_id: qbo_item_id, source: source, user_id: u.id)
	    		item.name = qbo_item_name
	    		item.user_id = u.id
	    		item.source = source if item.new_record?
	    		item.save!
	    		puts "Synced Item : #{qbo_item_name} with Id : #{qbo_item_id}"
	    	end
	    rescue Exception => ex
	    	puts "Exception : #{ex.inspect}"
	    end
    end
  end

  desc "Sync Tax Codes From QBO"
  task :sync_tax_codes => :environment do
    User.all.each do |u|
    	begin
	    	access_token = OAuth2::AccessToken.new($qb_consumer, u.qb_token, {refresh_token: u.refresh_token})
	    	new_access_token = access_token.refresh!
	    	result = TaxCode.sync_tax_codes_from_qbo(new_access_token.token, u.realm_id)
	    	result['IntuitResponse']['QueryResponse']['TaxCode'].each do |qbo_obj|
	    		qbo_id = qbo_obj["Id"]
	    		qbo_name = qbo_obj["Name"]
	    		tax_code = TaxCode.find_or_create_by(qbo_id: qbo_id, user_id: u.id)
	    		tax_code.name = qbo_name
	    		tax_code.user_id = u.id
	    		tax_code.save!
	    		puts "Synced TaxCode : #{qbo_name} with Id : #{qbo_id}"
	    	end
	    rescue Exception => ex
	    	puts "Exception : #{ex.inspect}"
	    end
    end
  end

  desc "Sync Payment Methods From QBO"
  task :sync_payment_methods => :environment do
    User.all.each do |u|
    	begin
    		source = PaymentMethod::SOURCE['Quickbook']
	    	access_token = OAuth2::AccessToken.new($qb_consumer, u.qb_token, {refresh_token: u.refresh_token})
	    	new_access_token = access_token.refresh!
	    	result = PaymentMethod.sync_payment_methods_from_qbo(new_access_token.token, u.realm_id)
	    	result['IntuitResponse']['QueryResponse']['PaymentMethod'].each do |qbo_obj|
	    		qbo_id = qbo_obj["Id"]
	    		qbo_name = qbo_obj["Name"]
	    		payment_method = PaymentMethod.find_or_create_by(qbo_id: qbo_id, source: source, user_id: u.id)
	    		payment_method.name = qbo_name
	    		payment_method.user_id = u.id
	    		payment_method.source = source if payment_method.new_record?
	    		payment_method.save!
	    		puts "Synced PaymentMethod : #{qbo_name} with Id : #{qbo_id}"
	    	end
	    rescue Exception => ex
	    	puts "Exception : #{ex.inspect}"
	    end
    end
  end

  desc "Sync Customers From QBO"
  task :sync_customers => :environment do
    User.all.each do |u|
    	begin
    		source = Customer::SOURCE['Quickbook']
	    	access_token = OAuth2::AccessToken.new($qb_consumer, u.qb_token, {refresh_token: u.refresh_token})
	    	new_access_token = access_token.refresh!
	    	result = Customer.sync_customers_from_qbo(new_access_token.token, u.realm_id)
	    	result['IntuitResponse']['QueryResponse']['Customer'].each do |qbo_obj|
	    		next unless qbo_obj["PrimaryEmailAddr"].present?
	    		qbo_id = qbo_obj["Id"]
	    		customer = Customer.find_or_create_by(qbo_id: qbo_id, source: source, user_id: u.id)

	    		customer.title = qbo_obj["Title"]
	    		customer.first_name = qbo_obj["GivenName"]
	    		customer.middle_name = qbo_obj["MiddleName"]
	    		customer.last_name = qbo_obj["FamilyName"]
	    		customer.suffix = qbo_obj["Suffix"]
	    		customer.display_name = qbo_obj["DisplayName"]
	    		customer.email = qbo_obj["PrimaryEmailAddr"]["Address"]
	    		customer.company_name = qbo_obj["CompanyName"]
	    		customer.phone = qbo_obj["PrimaryPhone"]["FreeFormNumber"] if qbo_obj["PrimaryPhone"].present?
	    		customer.mobile = qbo_obj["Mobile"]["FreeFormNumber"] if qbo_obj["Mobile"].present?
	    		customer.notes = qbo_obj["Notes"]
	    		if qbo_obj["BillAddr"].present?
	    			addr_obj = qbo_obj["BillAddr"]
		    		customer.address1 = addr_obj["Line1"]
		    		customer.city = addr_obj["City"]
		    		customer.state = addr_obj["CountrySubDivisionCode"]
		    		customer.country = addr_obj["Country"]
		    		customer.postal_code = addr_obj["PostalCode"]
	    		end
	    		customer.user_id = u.id
	    		customer.source = source if customer.new_record?
	    		if customer.save
	    			puts "Synced Customer : #{customer.first_name} #{customer.last_name} with Id : #{qbo_id}"
		    	else
		    		puts "Error : #{customer.errors.full_messages}"
		    	end
	    	end
	    rescue Exception => ex
	    	puts "***********Exception : #{ex.inspect} ***************"
	    	next
	    end
    end
  end
end