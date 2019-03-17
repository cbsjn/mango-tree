class SalesReceipt < ApplicationRecord
	belongs_to :customer
	belongs_to :payment_method
	belongs_to :user
	has_many :sales_receipt_details, dependent: :destroy
	validates :customer_id, :receipt_date, :presence => true
	PLACE_OF_SUPPLY = ['Delhi', 'Mumbai', 'Gurgaon', 'Kolkata', 'Chennai']
	DEPOSIT_TO = ['Cash']

  def self.not_synced(user)
    self.where("user_id = ? and qb_receipt_id IS NULL ", user.id)
  end

	def self.sync_receipt_to_qbo(user, sales_receipt)
		access_token = OAuth2::AccessToken.new($qb_consumer, user.qb_token, {refresh_token: user.refresh_token})
    new_access_token = access_token.refresh!

    sales_json = {
                  'TxnDate' => sales_receipt.receipt_date.strftime('%Y-%m-%d'),
                  'PaymentRefNum' => sales_receipt.reference_no, 
                  'TotalAmt' => sales_receipt.total_amt,
                  'PrivateNote' => sales_receipt.message, 
                  'PaymentMethodRef' => {
                                          'name' => sales_receipt.payment_method&.name,
                                          'value' => sales_receipt.payment_method_id
                                        },
                  'CustomerRef' => {
                                      'name' => sales_receipt.customer&.display_name, 
                                      'value' => sales_receipt.customer&.qbo_id
                                    },

                  'Line' => []
                  }
    sales_receipt.sales_receipt_details.each_with_index do |sd, index|
      sales_json['Line'] << { 
                              'Id' => index + 1,
                              'LineNum' => index + 1,
                              'Amount' => sd.amt,
                              'Description' => sd.product_description,
                              'DetailType' => 'SalesItemLineDetail',
                              'SalesItemLineDetail' => {
                                                        'Qty' => sd.qty,
                                                        'UnitPrice' => sd.rate,
                                                        'TaxCodeRef' => {
                                                          'value' => sd.tax_code_id
                                                        },
                                                        'ItemRef' => {
                                                          'value' => sd.item_id,
                                                          'name' => sd.item&.name
                                                        }
                              }
                            }
    end

    @result = HTTParty.post("#{BASE_API_URL}/company/#{user.realm_id}/salesreceipt", 
        :body => sales_json.to_json,
        :headers => { 'content-type' => 'application/json',
                      'Content-Type' => 'application/json',
                      Authorization: "Bearer #{new_access_token.token}" } 
        )
    result = Hash.from_xml(@result.body)
    qb_receipt_id = result['IntuitResponse']['SalesReceipt']['Id']
    sales_receipt.update_attributes(qb_receipt_id: qb_receipt_id)
	end
end
