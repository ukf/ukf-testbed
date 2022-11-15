# frozen_string_literal: true

#
# Module providing access to our fleet of validators.
#
module Testing
  require 'md-validator-client'

  #
  # Representation of an individual testing endpoint.
  #
  class Endpoint
    attr :name, :api

    def initialize(name, host)
      @name = name
      config = ValidatorClient::Configuration.new
      config.host = host
      client = ValidatorClient::ApiClient.new(config)
      @api = ValidatorClient::ValidationApi.new(client)
    end
  end

  #
  # Return all the API endpoints for the current environment.
  #
  # We use Rails conventions to determine the environment,
  # although we're not actually a Rails application.
  #
  def self.all_endpoints
    if ENV.fetch('RAILS_ENV', 'development') == 'development'
      [Endpoint.new('localhost', 'localhost:8080')]
    else
      [
        Endpoint.new('v09', 'v09:8080'), Endpoint.new('v09x', 'v09x:8080'),
        Endpoint.new('v010', 'v010:8080'), Endpoint.new('v010x', 'v010x:8080')
      ]
    end
  end
end
