class Reservation < ApplicationRecord
	belongs_to :customer
	belongs_to :user
	has_many :transactions
end
