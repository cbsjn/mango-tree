class SalesReceipt < ApplicationRecord
	belongs_to :customer
	belongs_to :payment_method
	belongs_to :user
	has_many :sales_receipt_details, dependent: :destroy
	validates :customer_id, :receipt_date, :presence => true
	PLACE_OF_SUPPLY = ['Delhi', 'Mumbai', 'Gurgaon', 'Kolkata', 'Chennai']
	DEPOSIT_TO = ['Cash']
end
