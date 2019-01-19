module SalesReceiptsHelper
	def get_customers
		cust_hash = {}
		Customer.synced(current_user).each do |c|
			cust_hash["#{c.title} #{c.first_name} #{c.middle_name} #{c.last_name} (#{c.display_name})"] = c.id
		end
		cust_hash
	end

	def get_payment_methods
		payment_method_hash = {}
		PaymentMethod.synced(current_user).each do |payment_method|
			payment_method_hash[payment_method.name] = payment_method.id
		end
		payment_method_hash
	end
end
