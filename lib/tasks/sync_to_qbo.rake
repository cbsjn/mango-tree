namespace :sync_to_qbo  do
  desc "Sync Customers To QBO"
  task :sync_customers => :environment do
    User.all.each do |u|
    	begin
    		customers = Customer.not_synced(u)
    		customers.each do |customer|
    			begin
    				result = Customer.sync_customers_to_qbo(u, customer)
    				if result
	    				puts "Customer Synced to QBO : #{customer.email}"
	    			else
	    				puts "Error Occurred while saving customer #{customer.email}"
	    			end
    			rescue Exception => ex
			    	puts "Inner Loop Exception : #{ex.inspect}"
			    	SyncingError.create(error_type: SyncingError::SYNC_CUSTOMER_TO_QBO, description: ex.message)
			    end
    		end
	    rescue Exception => ex
	    	puts "Outer Loop Exception : #{ex.inspect}"
	    end
    end
  end
end