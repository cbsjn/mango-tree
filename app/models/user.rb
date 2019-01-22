class User < ActiveRecord::Base
  attr_accessor :token
  has_many :customers
  has_many :items
  has_many :tax_codes
  has_many :sales_receipts
  validates :email,:uniqueness => true
  validates :email, :presence => true
  validates :password, :presence => true
  validates :password, :confirmation => true, :presence => true, :on => :create

  ROLES = {'Admin' => 1}

  before_create :encrypt_password

  def self.cloudbed_users
    self.where("cb_refresh_token IS NOT NULL")
  end

  def self.sync_access_tokens_from_cloudbeds(user)
    sleep 1 # cloudbeds allow max 5 calls / seconds so for safer side adding 1 call / second
    response = HTTParty.post("#{CLOUDBEDS_BASE_API_URL}/access_token", {
                          body: "client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}&refresh_token=#{user.cb_refresh_token}&grant_type=refresh_token",
                          headers: {
                            'Content-Type' => 'application/x-www-form-urlencoded',
                            'charset' => 'utf-8'
                          }
                        })
    return response
  end

  def self.authenticate(username, password)
    password = User::encrypt(password)
    username.present? && password.present? ? self.where("(email = ?  OR mobile = ? )AND password = ?", username, username, password).first : nil
  end

  def self.create_user(params)
    mobile = params[:mobile]
    name = params[:first_name].split(' ')
    first_name = name[0]
    last_name = name[1..4].join(' ')
    email = params[:email]
    password = params[:password]
    user = self.new(:email => email)
    user.first_name = first_name
    user.last_name = last_name
    user.mobile = mobile
    user.password = password
    user.role_id = params[:role_id]
    user
  end

  def self.encrypt(password)
    Digest::SHA1.hexdigest("#{password}")
  end
  protected
  def encrypt_password
    self.password = User.encrypt(self.password)
  end

end
