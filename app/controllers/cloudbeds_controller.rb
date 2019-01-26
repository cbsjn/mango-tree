class CloudbedsController < ApplicationController
  def oauth_callback
  	access_token = params['access_token']
  	refresh_token = params['refresh_token']
    puts "Params : #{params.inspect}"
    puts "**********************************"
  	puts "New Access Token : #{access_token}"
  	puts "New RefreshToken : #{refresh_token}"
  	if refresh_token.present? && access_token.present?
  		current_user.update_attributes(cb_refresh_token: refresh_token, cb_access_token: access_token, cb_token_generated_at: Time.now)
  	end
  	redirect_to root_path
  end
end
