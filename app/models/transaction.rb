class Transaction < ApplicationRecord
	belongs_to :customer
	belongs_to :user
	belongs_to :reservation

	def self.sync_transactions_from_cloudbeds(user, reservation_id)
    sleep 1
    sub_url = "propertyID=#{PROPERTY_ID}&reservationID=#{reservation_id}&includeDebit=true&includeCredit=true&transactionFilter=simple_transactions"
    response = HTTParty.get("#{CLOUDBEDS_BASE_API_URL}/getTransactions?#{sub_url}", {
                          headers: {
                            'Authorization' => "Bearer #{user.cb_access_token}"
                          }
                        })
    return response
  end
end
