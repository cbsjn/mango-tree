OAUTH_CONSUMER_KEY = "L0ghvx5WIQXNFDQm5UlnPM4u5V50l0WKPrpHyNlr0ZE74EvYYq"
OAUTH_CONSUMER_SECRET = "IxpZzBEdLd16xDCGT85YffV8nCn521m0GvPNI5YJ"

::QB_OAUTH_CONSUMER = OAuth::Consumer.new(OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET, {
    :site                 => "https://oauth.intuit.com",
    :request_token_path   => "/oauth/v1/get_request_token",
    :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
    :access_token_path    => "/oauth/v1/get_access_token"
})