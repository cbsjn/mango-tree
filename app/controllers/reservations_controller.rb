class ReservationsController < ApplicationController
  def index
  	@reservations = Reservation.where(filter_condition)
  															.paginate(page: params[:page], per_page: PAGINATION_COUNT)
  															.order("created_at desc")
  end

  def sync_invoice_to_quickbook
  	id = params[:id]
  	reservation = Reservation.where(id: id, user_id: session[:user_id]).first
  	if reservation.present?
      if reservation.customer&.qbo_id.present?
        user = current_user
        redirect_to transactions_path(reservation_id: id) and return if reservation&.qbo_invoice_id.present?
        invoices = Transaction.invoices(user, id)
        unless invoices.count.zero?
          begin
            Reservation.sync_invoice_to_qbo(user, invoices)
            flash[:notice] = "Invoice Synced Successfully with Invoice Number : #{qbo_invoice_number}"
          rescue Exception => ex
            flash[:warning] = ex
          end
        else
          flash[:warning] = 'No Invoices against this reservation'
        end
      else
        flash[:warning] = "Please Sync Customer first to Quickbook before syncing Invoices."
      end
    else
      flash[:warning] = 'Restricted Access'
    end
    redirect_to transactions_path(reservation_id: id)
  end

  private
  def filter_condition
  	customer_id = params[:customer_id]
  	condition = "user_id = #{session[:user_id]}"
  	condition += " and customer_id = #{customer_id}" if customer_id.present?
  	condition
  end
end
