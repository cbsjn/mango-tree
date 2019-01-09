module SalesReceiptsHelper
	def get_customers
		cust_hash = {}
		Customer.all.each do |c|
			cust_hash["#{c.first_name} #{c.middle_name} #{c.last_name}"] = c.id
		end
		cust_hash
	end
end
