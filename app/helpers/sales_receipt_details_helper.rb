module SalesReceiptDetailsHelper
	def get_items
		items_hash = {}
		Item.synced(current_user).each do |item|
			items_hash[item.name] = item.id
		end
		items_hash
	end

	def get_tax_codes
		tax_codes_hash = {}
		TaxCode.synced(current_user).each do |tax_code|
			tax_codes_hash[tax_code.name] = tax_code.id
		end
		tax_codes_hash
	end
end
