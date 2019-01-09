class SalesReceipt < ApplicationRecord
	belongs_to :customer
	has_many :sales_receipt_details, dependent: :destroy
	validates :customer_id, :receipt_date, :presence => true
	PLACE_OF_SUPPLY = ['Delhi', 'Mumbai', 'Gurgaon', 'Kolkata', 'Chennai']
	PAYMENT_METHOD = ['Cash', 'Cheque', 'Credit Card']
	DEPOSIT_TO = ['Cash']
end
