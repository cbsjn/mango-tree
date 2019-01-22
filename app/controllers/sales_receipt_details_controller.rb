class SalesReceiptDetailsController < ApplicationController
	def index
		redirect_to sales_receipts_path unless params[:sales_receipt_id].present?
		session[:sales_receipt_id] = params[:sales_receipt_id]
    @sales_receipt_details = SalesReceiptDetail.where(user_id: session[:user_id], sales_receipt_id: params[:sales_receipt_id])
  end

  def new
    @sales_receipt_detail = SalesReceiptDetail.new
  end

  def create
    @sales_receipt_detail = SalesReceiptDetail.new(sales_receipt_detail_params)
    if @sales_receipt_detail.save
      flash[:notice] = "SalesReceiptItem created successfully."
      redirect_to sales_receipt_details_path(sales_receipt_id: session[:sales_receipt_id])
    else
    	flash[:warning] = @sales_receipt_detail.errors.full_messages
      render :new
    end
  end

  def edit
    @sales_receipt_detail = SalesReceiptDetail.where(id: params[:id], user_id: session[:user_id]).first
    unless @sales_receipt_detail.present?
      flash[:warning] = 'Restricted Access'
      redirect_to sales_receipt_details_path(sales_receipt_id: session[:sales_receipt_id])
    end
  end

  def update
    @sales_receipt_detail = SalesReceiptDetail.find(params[:id])
    if @sales_receipt_detail.update_attributes(sales_receipt_detail_params)
      flash[:notice] = "SalesReceiptItem details have been updated successfully."
      redirect_to sales_receipt_details_path(sales_receipt_id: session[:sales_receipt_id])
    else
    	flash[:warning] = @sales_receipt_detail.errors.full_messages
      render :edit
    end
  end

  def show
  	@sales_receipt_detail = SalesReceiptDetail.where(id: params[:id], user_id: session[:user_id]).first
    if @sales_receipt_detail.present?
      @sales_receipt_detail.destroy
      flash[:notice] = "SalesReceiptItem deleted successfully."
    else
      flash[:warning] = 'Restricted Access'
    end
	  redirect_to sales_receipt_details_path(sales_receipt_id: session[:sales_receipt_id])
  end

  private
  # Using a private method to encapsulate the permissible parameters is
  # just a good pattern since you'll be able to reuse the same permit
  # list between create and update. Also, you can specialize this method
  # with per-user checking of permissible attributes.
  def sales_receipt_detail_params
  	params.require(:sales_receipt_detail).permit!
  end
end
