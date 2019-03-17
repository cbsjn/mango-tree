APP_CONFIG = YAML.load_file("#{Rails.root}/config/app_config.yml")[Rails.env]
PAGINATION_COUNT = 50
MAILCHIMP_API_KEY = '2f977dc2973306f59b5061d5a2090436-us20'
MAILCHIMP_LIST_ID = '6ca38b92e8'
Date::DATE_FORMATS[:default] = "%d/%m/%Y"
Time::DATE_FORMATS[:default] = "%d/%m/%Y %H:%M"