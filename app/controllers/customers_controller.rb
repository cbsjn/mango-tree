class CustomersController < ApplicationController
	def index
    @customers = Customer.where(filter_condition).paginate(page: params[:page], per_page: PAGINATION_COUNT).order("created_at desc, first_name asc")
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
    begin
      user = current_user
      cust = Customer.where(id: params[:id]).first
      # raise "#{new_access_token.token} ------------ #{new_access_token.refresh_token}"
      redirect_to customers_path if cust&.qbo_id.present?
      Customer.sync_customers_to_qbo(user, cust)
      flash[:notice] = "Customer Synced successfully to Quickbook with id : #{qbo_id}"
    rescue Exception => ex
      flash[:warning] = ex
    end
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

  def filter_condition
    month = params[:month].present? ? params[:month] : Time.now.strftime('%m-%Y')
    condition = "user_id = #{session[:user_id]}"
    condition += " AND extract(month from created_at) = #{month.split('-')[0]} and extract(year from created_at) = #{month.split('-')[1]}"
    condition += " AND first_name ilike '#{params[:customer_details]}%' OR cloudbed_guest_id = '#{params[:customer_details]}'"
    condition
  end
end
