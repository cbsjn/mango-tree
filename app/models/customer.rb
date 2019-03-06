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
    self.where("user_id = ? and qbo_id IS NOT NULL ", user.id).order(:first_name)
  end

  def self.not_synced(user)
    self.where("user_id = ? and qbo_id IS NULL ", user.id).order(:first_name)
  end

  def self.months(user)
    self.where("user_id = ?", user.id).pluck(:created_at).uniq
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

  def self.sync_customers_to_qbo(user, cust)
    access_token = OAuth2::AccessToken.new($qb_consumer, user.qb_token, {refresh_token: user.refresh_token})
    new_access_token = access_token.refresh!
    cust_json = {
            'FullyQualifiedName' => "#{cust.first_name} #{cust.last_name}", 
            'PrimaryEmailAddr' => {
              'Address' => cust.email
            }, 
            'DisplayName' => cust.display_name, 
            'Suffix' => cust.suffix, 
            'Title' => cust.title, 
            'MiddleName' => cust.middle_name, 
            'Notes' => cust.notes, 
            'FamilyName' => cust.last_name, 
            'PrimaryPhone' => {
              'FreeFormNumber' => cust.phone
            }, 
            'CompanyName' => cust.company_name, 
            'BillAddr' => {
              'CountrySubDivisionCode' => cust.state, 
              'City' => cust.city, 
              'PostalCode' => cust.postal_code, 
              'Line1' => cust.address1, 
              'Country' => cust.country
            }, 
            'GivenName' => cust.first_name
          }

    @result = HTTParty.post("#{BASE_API_URL}/company/#{user.realm_id}/customer", 
        :body => cust_json.to_json,
        :headers => { 'content-type' => 'application/json',
                      'Content-Type' => 'application/json',
                      Authorization: "Bearer #{new_access_token.token}" } 
        )
    result = Hash.from_xml(@result.body)
    qbo_id = result['IntuitResponse']['Customer']['Id']
    cust.update_attributes(qbo_id: qbo_id)
  end

  def self.cloudbed_customers(user)
    self.where("user_id = ? and source = ?", user.id, SOURCE['Cloudbeds']).order(:first_name)
  end
end
