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
    user = current_user
  	sales_receipt = SalesReceipt.find(params[:id])

    salesreceipt = Quickbooks::Model::SalesReceipt.new({
      customer_id: sales_receipt.customer.id,
      txn_date: Date.civil(2019, 01, 13),
      payment_ref_number: sales_receipt.reference_no, #optional payment reference number/string - e.g. stripe token
      deposit_to_account_id: 222, #The ID of the Account entity you want the SalesReceipt to be deposited to
      payment_method_id: 333 #The ID of the PaymentMethod entity you want to be used for this transaction
    })
    salesreceipt.auto_doc_number! #allows Intuit to auto-generate the transaction number

    line_item = Quickbooks::Model::Line.new
    line_item.amount = 50
    line_item.description = "Plush Baby Doll"
    line_item.sales_item! do |detail|
      detail.unit_price = 50
      detail.quantity = 1
      detail.item_id = 500 # Item (Product/Service) ID here
    end

    salesreceipt.line_items << line_item

    service = Quickbooks::Service::SalesReceipt.new({access_token: user.qb_token, company_id: user.realm_id })
    created_receipt = service.create(salesreceipt)


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
