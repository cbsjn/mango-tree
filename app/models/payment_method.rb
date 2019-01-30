class PaymentMethod < ApplicationRecord
	belongs_to :user
	has_many :sales_receipts
  # has_many :customers
  SOURCE = {'Quickbook' => 1, 'Cloudbeds' => 2, 'Website' => 3}
  
  def self.synced(user)
    self.where("user_id = ? and source = ? and qbo_id IS NOT NULL and qbo_id != '' ", user.id, SOURCE['Quickbook']).order(:name)
  end

	def self.sync_payment_methods_from_qbo(token, company_id)
    result = HTTParty.post("#{BASE_API_URL}/company/#{company_id}/query?query=select Name from PaymentMethod", 
    :headers => { 'content-type' => 'application/json',
                  'Content-Type' => 'application/json',
                  Authorization: "Bearer #{token}" } 
    )
    result = Hash.from_xml(result.body)
    result
	end

  def self.sync_payment_methods_from_cloudbeds(user)
    sleep 1
    response = HTTParty.get("#{CLOUDBEDS_BASE_API_URL}/getPaymentMethods", {
                          headers: {
                            'Authorization' => "Bearer #{user.cb_access_token}"
                          }
                        })
    return response
  end

  def self.payment_method(user, source)
    self.select(:id, :name).where("user_id = ? and source = ?", user.id, source)
  end
end
