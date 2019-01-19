class Customer < ApplicationRecord
	validates :email, :display_name, :uniqueness => true
  validates :first_name, :last_name, :display_name, :email, :company_name, :address1, :city, :state, :postal_code, :presence => true
  has_many :sales_receipts, dependent: :destroy
  belongs_to :user
  # belongs_to :payment_method

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
end
