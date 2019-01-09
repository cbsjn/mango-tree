class Customer < ApplicationRecord
	validates :email,:uniqueness => true
  validates :first_name, :last_name, :display_name, :email, :company_name, :mobile, :address1, :city, :state, :postal_code, :presence => true
  has_many :sales_receipts, dependent: :destroy
  STATUSES = {'Active' => true, 'DeActive' => false}
  TITLE = ['Mr.', 'Mrs.', 'Dr.']
  SUFFIX = ['Jr', 'Er']
end
