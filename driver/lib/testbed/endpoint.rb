# frozen_string_literal: true

#
# Module providing access to our testbed fleet of validators.
#
module Testbed
  require 'md-validator-client'

  #
  # Representation of an individual testing endpoint.
  #
  class Endpoint
    attr_reader :name, :api

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
        Endpoint.new('prod', 'prod:8080'),
        Endpoint.new('next', 'next:8080')
      ]
    end
  end
end
