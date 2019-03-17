class Transaction < ApplicationRecord
	belongs_to :customer
	belongs_to :user
	belongs_to :reservation

  def self.invoices(user, reservation_id)
    self.where("user_id = ? and reservation_id = ? and transaction_type = 'debit'", user.id, reservation_id)
  end

  def self.synced_invoices(user, reservation_id)
    self.where("user_id = ? and reservation_id = '?' and transaction_type = 'debit' and qbo_id IS NOT NULL", user.id, reservation_id)
  end

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

  def self.sync_payment_to_qbo(user, sales_receipt)
  end
end
