class SalesReceiptsController < ApplicationController
	def index
    @sales_receipts = SalesReceipt.all
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
    @sales_receipt = SalesReceipt.find(params[:id])
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
  	@sales_receipt = SalesReceipt.find(params[:id])
	  @sales_receipt.destroy
	  flash[:notice] = "SalesReceipt deleted successfully."
	  redirect_to sales_receipts_path
  end

  def sync_to_quickbook
  	sales_receipt = SalesReceipt.find(params[:id])
  	qb_sales_receipt_service = Quickbooks::Service::SalesReceipt.new
		qb_sales_receipt_service.company_id = COMPANY_ID 
		qb_sales_receipt_service.access_token = qb_token.token

  	qb_sales_receipt = Quickbooks::Model::SalesReceipt.new
		qb_sales_receipt.display_name = SalesReceipt.display_name
		qb_sales_receipt.email_address = SalesReceipt.email
		qb_sales_receipt.primary_phone = SalesReceipt.phone
		created_sales_receipt = qb_SalesReceipt_service.create(qb_SalesReceipt)

		created_sales_receipt_id = created_sales_receipt.id
		created_sales_receipt_name = created_sales_receipt.display_name
  	flash[:notice] = "SalesReceipt Synced successfully to Quickbook. #{created_sales_receipt.id}"
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
