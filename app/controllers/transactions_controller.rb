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
  end

  private
  def filter_condition
  	customer_id = params[:customer_id]
  	condition = "user_id = #{session[:user_id]}"
  	condition += " and customer_id = #{customer_id}" if customer_id.present?
  	condition
  end
end
