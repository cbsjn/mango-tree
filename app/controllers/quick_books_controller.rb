class QuickBooksController < ApplicationController 

	def index 
	end 
	

  def authenticate
    callback = quick_books_oauth_callback_url
    token = $qb_consumer.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = token
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

	def create_customer 
		@customer_service = Quickbooks::Service::Customer.new 
		access_token = OAuth::AccessToken.new($qb_consumer, session[:token], session[:secret] ) 
		@customer_service.access_token = access_token 
		@customer_service.company_id = session[:realm_id] # realm_id is your company_id customer = Quickbooks::Model::Customer.new customer.given_name = "test" # Customer Name (Unique) customer.email_address = "test@buffercode.in" # Customer Email @customer_id = @customer_service.create(customer) if(!@customer_id.blank?) self.create_invoice(@customer_id) # Call Invoice Create Function end end def authenticate callback = quick_books_oauth_callback_url token = QB_OAUTH_CONSUMER.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = Marshal.dump(token)
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def oauth_callback
    at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    session[:token] = at.token  # Insert Quickbooks Access token into Session
    session[:secret] = at.secret # Insert Quickbooks Secret into Session
    session[:realm_id] = params['realmId'] # Insert Company ID into Session
    redirect_to root_url
  end

  def create_invoice(customer)
    access_token = OAuth::AccessToken.new($qb_consumer, session[:token], session[:secret] )
    invoice = Quickbooks::Model::Invoice.new
    invoice.customer_id = customer.id # Customer Id
    invoice.txn_date = Date.civil(2016, 10, 04) # Date of Invoice
    invoice.doc_number = "38" # my custom Invoice # - can leave blank to have Intuit auto-generate it
    line_item = Quickbooks::Model::InvoiceLineItem.new
    line_item.amount = 50  # Item Price
    line_item.description = "My Cute Baby" #Item Description
    line_item.sales_item! do |detail|
      detail.unit_price = 50 # Unit Price
      detail.quantity = 1 # Quantity Details
      detail.item_id = 1 # Item ID here
    end
    invoice.line_items << line_item
    service = Quickbooks::Service::Invoice.new
    service.company_id = session[:realm_id]
    service.access_token = access_token
    created_invoice = service.create(invoice)
    invoice = service.fetch_by_id(created_invoice.id)
    raw_pdf_data = service.pdf(invoice)

    # make invoice heard copy in public folder

    File.open("invoice.pdf", "wb") do |file|
      file.write(raw_pdf_data)
    end
  end

  def destory_sesssion  # Destroy All Session Variable after use
    session[:token] = nil
    session[:secret] = nil
    session[:realm_id] = nil
  end

end