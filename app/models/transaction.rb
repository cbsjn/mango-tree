class Transaction < ApplicationRecord
	belongs_to :customer
	belongs_to :user
	belongs_to :reservation

  def self.invoices(user, reservation_id)
    self.where("user_id = ? and reservation_id = ? and transaction_type = 'debit'", user.id, reservation_id)
  end

  def self.payments(user)
    self.where("user_id = ? and transaction_type = 'credit' and qbo_id IS NULL", user.id)
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

  def self.sync_payment_to_qbo(user, reservation, transaction, synced_invoices, qbo_payment_method_id)
    access_token = OAuth2::AccessToken.new($qb_consumer, user.qb_token, {refresh_token: user.refresh_token})
    new_access_token = access_token.refresh!
    payment_json = {
                    'TxnDate' => transaction.transaction_date.strftime('%Y-%m-%d'),
                    'TotalAmt' => synced_invoices.sum(&:amount),
                    'PaymentMethodRef' => {
                                            'value' => qbo_payment_method_id
                                          },
                    'CustomerRef' => {
                                        'value' => transaction.customer&.qbo_id
                                      },

                    'Line' => []
                    }

    payment_json['Line'] << { 
                      'Amount' => synced_invoices.sum(&:amount),
                      'Description' => reservation.qbo_invoice_number,
                      'LinkedTxn' => [{
                                        'TxnId' => reservation.qbo_invoice_id,
                                        'TxnType' => 'Invoice'
                                      }]
                    }

    @result = HTTParty.post("#{BASE_API_URL}/company/#{user.realm_id}/payment", 
        :body => payment_json.to_json,
        :headers => { 'content-type' => 'application/json',
                      'Content-Type' => 'application/json',
                      Authorization: "Bearer #{new_access_token.token}" } 
        )
    result = Hash.from_xml(@result.body)
    qbo_payment_id = result['IntuitResponse']['Payment']['Id']
    transaction.update_attributes(qbo_id: qbo_payment_id)
  end
end
