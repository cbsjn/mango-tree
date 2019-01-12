class QuickBooksController < ApplicationController 

	def index 
	end 

  def authenticate
    redirect_uri = quick_books_oauth_callback_url
    grant_url = $qb_consumer.auth_code.authorize_url(:redirect_uri => redirect_uri, :response_type => "code", :state => SecureRandom.hex(12), :scope => "com.intuit.quickbooks.accounting")
    redirect_to grant_url
  end

  def oauth_callback
    if params[:state]
      redirect_uri = quick_books_oauth_callback_url
      if resp = $qb_consumer.auth_code.get_token(params[:code], :redirect_uri => redirect_uri)
        session[:token] = resp.token
        current_user.update_attributes(qb_token: resp.token, refresh_token: resp.refresh_token, realm_id: params[:realmId], code: params[:code], token_generated_at: Time.zone.now)
      end
    end
  end

  def oauth_callback2
    #at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    #raise at.inspect
    # at = session[:qb_request_token].get_access_token(:oauth_verifier => params[:oauth_verifier])
    resp = oauth2_client.access_token!
    # raise"---ACCESS TOKEN --- #{resp.access_token}------REFRESH TOKEN ---- #{resp.refresh_token}"
    session[:token] = resp.access_token  # Insert Quickbooks Access token into Session
    session[:refresh_token] = resp.refresh_token
    session[:secret] = OAUTH_CONSUMER_SECRET # Insert Quickbooks Secret into Session
    session[:realm_id] = params[:realmId] # Insert Company ID into Session
    session[:code] = params[:code]
    session[:state] = params[:state]
    puts session[:token].inspect
    puts '----------------------------------'
    current_user.update_attributes(qb_token: session[:token], refresh_token: session[:refresh_token], secret: session[:secret], realm_id: session[:realm_id], code: session[:code], state: session[:state], token_generated_at: Time.zone.now)

    @result = HTTParty.post('https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer', 
        :body => { :grant_type => 'authorization_code', 
                   :code => params[:code], 
                   :redirect_uri => 'http://localhost:3000/oauth_callback'
                 }.to_json,
        :headers => { 'Content-Type' => 'application/x-www-form-urlencoded',
                      Host: 'oauth.platform.intuit.com',
                      Authorization: "Basic " + Base64.encode64("L0ghvx5WIQXNFDQm5UlnPM4u5V50l0WKPrpHyNlr0ZE74EvYYq:IxpZzBEdLd16xDCGT85YffV8nCn521m0GvPNI5YJ"),
                      Accept: 'application/json'
                      } )
      raise @result.body.inspect

    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{params[:code]}") and return
  end

  def destory_sesssion  # Destroy All Session Variable after use
    session[:token] = nil
    session[:secret] = nil
    session[:realm_id] = nil
  end

end