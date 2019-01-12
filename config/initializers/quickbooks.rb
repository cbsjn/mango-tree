OAUTH_CONSUMER_KEY = "L0ghvx5WIQXNFDQm5UlnPM4u5V50l0WKPrpHyNlr0ZE74EvYYq"
OAUTH_CONSUMER_SECRET = "IxpZzBEdLd16xDCGT85YffV8nCn521m0GvPNI5YJ"
COMPANY_ID = 123146245982354

APP_CENTER_BASE            = 'https://appcenter.intuit.com'
APP_CENTER_URL             =  APP_CENTER_BASE + '/Connect/Begin?oauth_token='
APP_CONNECTION_URL         = APP_CENTER_BASE + '/api/v1/connection'
  
# OAUTH_CONSUMER_KEY = 'Q0g1nvFjRn5Yrm0XFMJLCM9lb71UFxnqoa6UyUb4DoTQY9Tp7P'
# OAUTH_CONSUMER_SECRET = '9lkICZLKe7AirxoRp54kNAP6U3IhZKQD3imwPH8J'
$qb_consumer = OAuth::Consumer.new(OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET, {
    :site                 => "https://oauth.intuit.com",
    :request_token_path   => "/oauth/v1/get_request_token",
    :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
    :access_token_path    => "/oauth/v1/get_access_token"
})

Quickbooks.sandbox_mode = true