class CustomersController < ApplicationController
	def index
    @customers = Customer.all
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
    @customer = Customer.find(params[:id])
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
  	@customer = Customer.find(params[:id])
	  @customer.destroy
	  flash[:notice] = "Customer deleted successfully."
	  redirect_to customers_path
  end

  def sync_to_quickbook
  	customer = Customer.find(params[:id])
  	qb_customer_service = Quickbooks::Service::Customer.new
		qb_customer_service.company_id = COMPANY_ID 
		qb_customer_service.access_token = qb_token.token

  	qb_customer = Quickbooks::Model::Customer.new
		qb_customer.display_name = customer.display_name
		qb_customer.email_address = customer.email
		qb_customer.primary_phone = customer.phone
		created_customer = qb_customer_service.create(qb_customer)

		created_customer_id = created_customer.id
		created_customer_name = created_customer.display_name
  	flash[:notice] = "Customer Synced successfully to Quickbook. #{created_customer_id}"
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
