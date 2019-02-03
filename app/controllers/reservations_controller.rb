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

        access_token = OAuth2::AccessToken.new($qb_consumer, user.qb_token, {refresh_token: user.refresh_token})
        new_access_token = access_token.refresh!

        invoices = Transaction.invoices(user, id)

        unless invoices.count.zero?
          invoice_json = {
                          'TxnDate' => invoices.first.transaction_date.strftime('%Y-%m-%d'),
                          'TotalAmt' => invoices.sum(&:amount),
                          'CustomerRef' => {
                                              'value' => reservation.customer&.qbo_id
                                            },

                          'Line' => []
                          }


          invoices.each_with_index do |invoice, index|
            invoice_json['Line'] << { 
                              'Id' => index + 1,
                              'LineNum' => index + 1,
                              'Amount' => invoice.amount,
                              'Description' => invoice.description,
                              'DetailType' => 'SalesItemLineDetail',
                              'SalesItemLineDetail' => {
                                                        'Qty' => invoice.quantity,
                                                        'UnitPrice' => (invoice.amount.to_f/invoice.quantity.to_f),
                                                        'TaxCodeRef' => {
                                                          'value' => '23'
                                                        },
                                                        'ItemRef' => {
                                                          'value' => Item.get_qbo_mapped_item(user.id, invoice)
                                                        }
                              }
                            }
          end



          @result = HTTParty.post("#{BASE_API_URL}/company/#{user.realm_id}/invoice", 
              :body => invoice_json.to_json,
              :headers => { 'content-type' => 'application/json',
                            'Content-Type' => 'application/json',
                            Authorization: "Bearer #{new_access_token.token}" } 
              )
          result = Hash.from_xml(@result.body)
          qbo_invoice_id = result['IntuitResponse']['Invoice']['Id']
          qbo_invoice_number = result['IntuitResponse']['Invoice']['DocNumber']
          reservation.update_attributes(qbo_invoice_id: qbo_invoice_id, qbo_invoice_number: qbo_invoice_number)
          invoices.update_all(qbo_id: qbo_invoice_id)

      	  flash[:notice] = "Invoice Synced Successfully with Invoice Number : #{qbo_invoice_number}"
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
