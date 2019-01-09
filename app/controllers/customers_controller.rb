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
  	flash[:notice] = "Customer Synced successfully to Quickbook."
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
