module CustomersHelper
	def months_dropdown
		month_hash = {}
		Customer.months(current_user).each do |date|
			month_hash[date.strftime('%b %Y')] = date.strftime('%m-%Y')
		end
		month_hash
	end
end
