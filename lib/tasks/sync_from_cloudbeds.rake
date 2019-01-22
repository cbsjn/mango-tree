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
		    	u.update_attributes(cb_refresh_token: refresh_token, cb_access_token: access_token, cb_token_generated_at: Time.now)
		    	puts "Synced Access Token For user : #{u.first_name} with Id : #{u.id}"
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
	    	result['data']['methods'].each do |obj|
	    		code = obj["method"]
	    		name = obj["name"]
	    		source = PaymentMethod::SOURCE['Cloudbeds']
	    		payment_method = PaymentMethod.find_or_create_by(source: source, code: code)
	    		payment_method.name = name
	    		payment_method.user_id = u.id
	    		payment_method.source = source if payment_method.new_record?
	    		payment_method.save!
	    		puts "Synced PaymentMethod : #{name}"
	    	end
	    rescue Exception => ex
	    	puts "Exception : #{ex.inspect}"
	    end
    end
  end
end