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
