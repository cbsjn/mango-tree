class TransactionsController < ApplicationController
	def index
    @transactions = Transaction.where(filter_condition)
													    .paginate(page: params[:page], per_page: PAGINATION_COUNT)
													    .order("created_at desc")
  end

  def show
  	@transaction = Transaction.where(id: params[:id], user_id: session[:user_id]).first
    unless @transaction.present?
      flash[:warning] = 'Restricted Access'
      redirect_to transactions_path
    end
  end

  def sync_to_quickbook
  	transaction_id = params[:id]
  	transaction = Transaction.where(id: transaction_id, user_id: session[:user_id]).first
  	if transaction.present?
      reservation = transaction.reservation
      unless reservation.qbo_invoice_id.present?
        flash[:warning] = 'Please Create Invoice for before Syncing Payment.'
        redirect_to transactions_path(reservation_id: reservation.id) and return
      end
      redirect_to transactions_path(reservation_id: reservation.id) and return if transaction&.qbo_id.present?

      user = current_user

      synced_invoices = Transaction.synced_invoices(user, reservation.id)
      qbo_payment_method_id = PaymentMethod.get_qbo_mapped_payment_method(user.id, transaction.category)

      if qbo_payment_method_id.present?
        begin
          qbo_payment_id = Transaction.sync_payment_to_qbo(user, reservation, transaction, synced_invoices, qbo_payment_method_id)
          flash[:notice] = "Payment Synced Successfully with QBO ID : #{qbo_payment_id}."
        rescue Exception => ex
          flash[:warning] = ex
        end
      else
        flash[:warning] = 'Please Create Mapping of PaymentMethod before syncing.'
      end
      redirect_to transactions_path(reservation_id: reservation.id)
  	else
  		flash[:warning] = 'Restricted Access'
      redirect_to transactions_path
  	end
  end

  private
  def filter_condition
  	customer_id = params[:customer_id]
  	reservation_id = params[:reservation_id]
  	condition = "user_id = #{session[:user_id]}"
  	condition += " and customer_id = #{customer_id}" if customer_id.present?
  	condition += " and reservation_id = '#{reservation_id}'" if reservation_id.present?
  	condition
  end
end
