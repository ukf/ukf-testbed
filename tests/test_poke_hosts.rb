require 'new_api'
require 'pp'

def poke_host(api)
  puts "\nPoking #{api.api_client.config.host}..."
  begin
    # lists available validators
    result = api.get_validators
    puts "Validators detected: #{result.length}"
    result.each do |val|
      puts "   #{val.validator_id}: #{val.description}"
    end
  rescue ValidatorClient::ApiError => e
    puts "Exception when calling ValidationApi->get_validators: #{e}"
  end
end

all_apis.each { |api| poke_host(api) }
