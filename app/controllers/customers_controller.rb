class CustomersController < ApplicationController
	def index
    @customers = Customer.where(user_id: session[:user_id]).paginate(page: params[:page], per_page: PAGINATION_COUNT).order("first_name, last_name")
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)
    if @customer.save
      flash[:notice] = "Customer created successfully."
      redirect_to customers_path
    else
    	flash[:warning] = @customer.errors.full_messages
      render :new
    end
  end

  def edit
    @customer = Customer.where(id: params[:id], user_id: session[:user_id]).first
    unless @customer.present?
      flash[:warning] = 'Restricted Access'
      redirect_to customers_path
    end
  end

  def update
    @customer = Customer.find(params[:id])
    if @customer.update_attributes(customer_params)
      flash[:notice] = "Customer details have been updated successfully."
      redirect_to customers_path
    else
    	flash[:warning] = @customer.errors.full_messages
      render :edit
    end
  end

  def show
  	@customer = Customer.where(id: params[:id], user_id: session[:user_id]).first
    if @customer.present?
  	  @customer.destroy
  	  flash[:notice] = "Customer deleted successfully."
    else
      flash[:warning] = 'Restricted Access'
    end
	  redirect_to customers_path
  end

  def sync_to_quickbook
    user = current_user
    cust = Customer.where(id: params[:id]).first
    access_token = OAuth2::AccessToken.new($qb_consumer, user.qb_token, {refresh_token: user.refresh_token})
    new_access_token = access_token.refresh!
    # raise "#{new_access_token.token} ------------ #{new_access_token.refresh_token}"
    redirect_to customers_path if cust&.qbo_id.present?
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
      flash[:notice] = "Customer Synced successfully to Quickbook with id : #{qbo_id}"
      redirect_to customers_path
  end

  private
  # Using a private method to encapsulate the permissible parameters is
  # just a good pattern since you'll be able to reuse the same permit
  # list between create and update. Also, you can specialize this method
  # with per-user checking of permissible attributes.
  def customer_params
  	params.require(:customer).permit!
  end
end
