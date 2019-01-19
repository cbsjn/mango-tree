class SalesReceiptsController < ApplicationController
	def index
    @sales_receipts = SalesReceipt.where(user_id: session[:user_id])
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
  	@sales_receipt = SalesReceipt.find(params[:id])
	  @sales_receipt.destroy
	  flash[:notice] = "SalesReceipt deleted successfully."
	  redirect_to sales_receipts_path
  end

  def sync_to_quickbook
    user = current_user
    sales_receipt = SalesReceipt.where(id: params[:id]).first
    redirect_to sales_receipts_path if sales_receipt&.qb_receipt_id.present?

    access_token = OAuth2::AccessToken.new($qb_consumer, user.qb_token, {refresh_token: user.refresh_token})
    new_access_token = access_token.refresh!

    sales_json = {
                  'TxnDate' => sales_receipt.receipt_date.strftime('%Y-%m-%d'),
                  'PaymentRefNum' => sales_receipt.reference_no, 
                  'TotalAmt' => sales_receipt.total_amt,
                  'PrivateNote' => sales_receipt.message, 
                  'PaymentMethodRef' => {
                                          'name' => sales_receipt.payment_method&.name,
                                          'value' => sales_receipt.payment_method_id
                                        },
                  'CustomerRef' => {
                                      'name' => sales_receipt.customer&.display_name, 
                                      'value' => sales_receipt.customer&.qbo_id
                                    },

                  'Line' => []
                  }
    sales_receipt.sales_receipt_details.each_with_index do |sd, index|
      sales_json['Line'] << { 
                              'Id' => index + 1,
                              'LineNum' => index + 1,
                              'Amount' => sd.amt,
                              'Description' => sd.product_description,
                              'DetailType' => 'SalesItemLineDetail',
                              'SalesItemLineDetail' => {
                                                        'Qty' => sd.qty,
                                                        'UnitPrice' => sd.rate,
                                                        'TaxCodeRef' => {
                                                          'value' => sd.tax_code_id
                                                        },
                                                        'ItemRef' => {
                                                          'value' => sd.item_id,
                                                          'name' => sd.item&.name
                                                        }
                              }
                            }
    end

    @result = HTTParty.post("#{BASE_API_URL}/company/#{user.realm_id}/salesreceipt", 
        :body => sales_json.to_json,
        :headers => { 'content-type' => 'application/json',
                      'Content-Type' => 'application/json',
                      Authorization: "Bearer #{new_access_token.token}" } 
        )
    result = Hash.from_xml(@result.body)
    qb_receipt_id = result['IntuitResponse']['SalesReceipt']['Id']
    sales_receipt.update_attributes(qb_receipt_id: qb_receipt_id)

    flash[:notice] = "SalesReceipt Synced successfully to Quickbook with ID : #{qb_receipt_id}"
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
