class SalesReceiptDetail < ApplicationRecord
	belongs_to :sales_receipt
	belongs_to :item
	before_save :save_amount
	after_save :save_total_qty_and_amt

	private
	def save_amount
		self.amt = (self.qty * self.rate)
	end

	def save_total_qty_and_amt
		total_qty = self.sales_receipt.sales_receipt_details.sum(&:qty)
		total_amt = self.sales_receipt.sales_receipt_details.sum(&:amt)
		self.sales_receipt.update_attributes(total_qty: total_qty, total_amt: total_amt)
	end
end
