# frozen_string_literal: true

require 'md-validator-client'

#
# Default configuration.
#
ValidatorClient.configure do |config|
  config.host = 'localhost:8080'
end

#
# Make a new API object based on the provided host.
#
def new_api(host)
  config = ValidatorClient::Configuration.new
  config.host = host
  client = ValidatorClient::ApiClient.new(config)
  ValidatorClient::ValidationApi.new(client)
end

#
# Return all the API endpoints for the current environment.
#
# We use Rails conventions to determine the environment,
# although we're not actually a Rails application.
#
def all_apis
  if ENV.fetch('RAILS_ENV', 'development') == 'development'
    [new_api('localhost:8080')]
  else
    [
      new_api('v09:8080'), new_api('v09x:8080'),
      new_api('v010:8080'), new_api('v010x:8080')
    ]
  end
end
