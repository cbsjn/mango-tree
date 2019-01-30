class Customer < ApplicationRecord
	validates :email, :display_name, :uniqueness => true
  validates :first_name, :last_name, :display_name, :email, :company_name, :address1, :city, :state, :postal_code, :presence => true
  has_many :sales_receipts, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :transactions
  belongs_to :user
  # belongs_to :payment_method
  SOURCE = {'Quickbook' => 1, 'Cloudbeds' => 2, 'Website' => 3}

  STATUSES = {'Active' => true, 'DeActive' => false}
  TITLE = ['Mr.', 'Mrs.', 'Dr.']
  SUFFIX = ['Jr', 'Er']

  def self.synced(user)
    self.where("user_id = ? and qbo_id IS NOT NULL", user.id).order(:first_name)
  end

  def self.sync_customers_from_qbo(token, company_id)
    result = HTTParty.post("#{BASE_API_URL}/company/#{company_id}/query?query=select * from Customer", 
    :headers => { 'content-type' => 'application/json',
                  'Content-Type' => 'application/json',
                  Authorization: "Bearer #{token}" } 
    )
    result = Hash.from_xml(result.body)
    result
	end

  def self.sync_checked_out_guests(user, checkout_date)
    sleep 1
    sub_url = "propertyID=#{PROPERTY_ID}&checkOutFrom=#{checkout_date}&checkOutTo=#{checkout_date}&status=checked_out&includeGuestInfo=true"
    response = HTTParty.get("#{CLOUDBEDS_BASE_API_URL}/getGuestList?#{sub_url}", {
                          headers: {
                            'Authorization' => "Bearer #{user.cb_access_token}"
                          }
                        })
    return response
  end

  def self.cloudbed_customers(user)
    self.where("user_id = ? and source = ?", user.id, SOURCE['Cloudbeds']).order(:first_name)
  end
end
