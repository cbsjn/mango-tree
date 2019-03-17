class SalesReceiptsController < ApplicationController
	def index
    @sales_receipts = SalesReceipt.where(user_id: session[:user_id]).paginate(page: params[:page], per_page: PAGINATION_COUNT).order("receipt_date")
  end

  def new
    @sales_receipt = SalesReceipt.new
  end

  def create
    @sales_receipt = SalesReceipt.new(sales_receipt_params)
    if @sales_receipt.save
      flash[:notice] = "SalesReceipt created successfully."
      redirect_to sales_receipts_path
    else
    	flash[:warning] = @sales_receipt.errors.full_messages
      render :new
    end
  end

  def edit
    @sales_receipt = SalesReceipt.where(id: params[:id], user_id: session[:user_id]).first
    unless @sales_receipt.present?
      flash[:warning] = 'Restricted Access'
      redirect_to sales_receipts_path
    end
  end

  def update
    @sales_receipt = SalesReceipt.find(params[:id])
    if @sales_receipt.update_attributes(sales_receipt_params)
      flash[:notice] = "SalesReceipt details have been updated successfully."
      redirect_to sales_receipts_path
    else
    	flash[:warning] = @sales_receipt.errors.full_messages
      render :edit
    end
  end

  def show
  	@sales_receipt = SalesReceipt.where(id: params[:id], user_id: session[:user_id]).first
    if @sales_receipt.present?
  	  @sales_receipt.destroy
  	  flash[:notice] = "SalesReceipt deleted successfully."
    else
      flash[:warning] = 'Restricted Access'
    end
	  redirect_to sales_receipts_path
  end

  def sync_to_quickbook
    begin
      user = current_user
      sales_receipt = SalesReceipt.where(id: params[:id]).first
      redirect_to sales_receipts_path if sales_receipt&.qb_receipt_id.present?
      SalesReceipt.sync_receipt_to_qbo(user, sales_receipt)
      
      flash[:notice] = "SalesReceipt Synced successfully to Quickbook with ID : #{qb_receipt_id}"
    rescue Exception => ex
      flash[:warning] = ex
    end
    redirect_to sales_receipts_path
  end

  private
  # Using a private method to encapsulate the permissible parameters is
  # just a good pattern since you'll be able to reuse the same permit
  # list between create and update. Also, you can specialize this method
  # with per-user checking of permissible attributes.
  def sales_receipt_params
  	params.require(:sales_receipt).permit!
  end
end
