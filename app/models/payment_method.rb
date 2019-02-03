class PaymentMethod < ApplicationRecord
	belongs_to :user
	has_many :sales_receipts
  # has_many :customers
  validates :name, uniqueness: { scope: [:user_id, :source], message: "PaymentMethod Already Exists." }

  SOURCE = {'Quickbook' => 1, 'Cloudbeds' => 2, 'Website' => 3}
  
  def self.synced(user)
    self.where("user_id = ? and source = ? and qbo_id IS NOT NULL", user.id, SOURCE['Quickbook']).order(:name)
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

  def self.get_qbo_mapped_payment_method(user_id, cloudbed_payment_method)
    cb_pm_id = self.where(name: cloudbed_payment_method, user_id: user_id, source: SOURCE['Cloudbeds']).first.id
    qb_pm_id = Mapping.where(user_id: user_id, cloudbed_id: cb_pm_id, name: 'PaymentMethod').first&.qbo_id
    self.find(qb_pm_id).qbo_id
  end
end
