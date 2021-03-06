OAUTH_CONSUMER_KEY = ENV['OAUTH_CONSUMER_KEY'] || "Q0g1nvFjRn5Yrm0XFMJLCM9lb71UFxnqoa6UyUb4DoTQY9Tp7P"
OAUTH_CONSUMER_SECRET = ENV['OAUTH_CONSUMER_SECRET'] || "9lkICZLKe7AirxoRp54kNAP6U3IhZKQD3imwPH8J"
COMPANY_ID = ENV['COMPANY_ID'] || 123146231153709

APP_CENTER_BASE            = 'https://appcenter.intuit.com'
APP_CENTER_URL             =  APP_CENTER_BASE + '/Connect/Begin?oauth_token='
APP_CONNECTION_URL         = APP_CENTER_BASE + '/api/v1/connection'
BASE_API_URL = 'https://sandbox-quickbooks.api.intuit.com/v3'
=begin  
# OAUTH_CONSUMER_KEY = 'Q0g1nvFjRn5Yrm0XFMJLCM9lb71UFxnqoa6UyUb4DoTQY9Tp7P'
# OAUTH_CONSUMER_SECRET = '9lkICZLKe7AirxoRp54kNAP6U3IhZKQD3imwPH8J'
$qb_consumer = OAuth::Consumer.new(OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET, {
    :site                 => "https://oauth.intuit.com",
    :request_token_path   => "/oauth/v1/get_request_token",
    :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
    :access_token_path    => "/oauth/v1/get_access_token"
})
=end


oauth_params = {
  :site => "https://appcenter.intuit.com/connect/oauth2",
  :authorize_url => "https://appcenter.intuit.com/connect/oauth2",
  :token_url => "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer"
}

$qb_consumer = OAuth2::Client.new(OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET, oauth_params)

Quickbooks.sandbox_mode = true