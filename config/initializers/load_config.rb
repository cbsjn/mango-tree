APP_CONFIG = YAML.load_file("#{Rails.root}/config/app_config.yml")[Rails.env]

Date::DATE_FORMATS[:default] = "%d/%m/%Y"
Time::DATE_FORMATS[:default] = "%d/%m/%Y %H:%M"