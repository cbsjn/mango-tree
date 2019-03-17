class Reservation < ApplicationRecord
	belongs_to :customer
	belongs_to :user
	has_many :transactions

  def self.not_synced(user)
    self.where("user_id = ? and qbo_invoice_id IS NULL ", user.id)
  end

	def self.sync_invoice_to_qbo(user, invoices)
		access_token = OAuth2::AccessToken.new($qb_consumer, user.qb_token, {refresh_token: user.refresh_token})
	  new_access_token = access_token.refresh!

    invoice_json = {
                    'TxnDate' => invoices.first.transaction_date.strftime('%Y-%m-%d'),
                    'TotalAmt' => invoices.sum(&:amount),
                    'CustomerRef' => {
                                        'value' => reservation.customer&.qbo_id
                                      },

                    'Line' => []
                    }


    invoices.each_with_index do |invoice, index|
      invoice_json['Line'] << { 
                        'Id' => index + 1,
                        'LineNum' => index + 1,
                        'Amount' => invoice.amount,
                        'Description' => invoice.description,
                        'DetailType' => 'SalesItemLineDetail',
                        'SalesItemLineDetail' => {
                                                  'Qty' => invoice.quantity,
                                                  'UnitPrice' => (invoice.amount.to_f/invoice.quantity.to_f),
                                                  'TaxCodeRef' => {
                                                    'value' => '23'
                                                  },
                                                  'ItemRef' => {
                                                    'value' => Item.get_qbo_mapped_item(user.id, invoice)
                                                  }
                        }
                      }
    end
    @result = HTTParty.post("#{BASE_API_URL}/company/#{user.realm_id}/invoice", 
        :body => invoice_json.to_json,
        :headers => { 'content-type' => 'application/json',
                      'Content-Type' => 'application/json',
                      Authorization: "Bearer #{new_access_token.token}" } 
        )
    result = Hash.from_xml(@result.body)
    qbo_invoice_id = result['IntuitResponse']['Invoice']['Id']
    qbo_invoice_number = result['IntuitResponse']['Invoice']['DocNumber']
    reservation.update_attributes(qbo_invoice_id: qbo_invoice_id, qbo_invoice_number: qbo_invoice_number)
    invoices.update_all(qbo_id: qbo_invoice_id)
	end
end
