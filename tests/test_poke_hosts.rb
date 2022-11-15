# frozen_string_literal: true

require 'testing'

def poke_host(endpoint)
  puts "\nPoking #{endpoint.name}..."
  begin
    # lists available validators
    result = endpoint.api.get_validators
    puts "Validators detected: #{result.length}"
    result.each do |val|
      puts "   #{val.validator_id}: #{val.description}"
    end
  rescue ValidatorClient::ApiError => e
    puts "Exception when calling ValidationApi->get_validators: #{e}"
  end
end

Testing.all_endpoints.each { |endpoint| poke_host(endpoint) }
