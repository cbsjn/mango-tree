class PaymentMethod < ApplicationRecord
	belongs_to :user
	has_many :sales_receipts

  def self.synced(user)
    self.where("user_id = ? and qbo_id IS NOT NULL", user.id).order(:name)
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
end
