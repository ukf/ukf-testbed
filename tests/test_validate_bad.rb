require 'new_api'
require 'pp'

def try_validate(api)
  puts "\nPoking #{api.api_client.config.host}..."
  metadata = IO.read 'tests/test_validate_bad.xml'
  begin
    results = api.validate('default', metadata)
    puts "Validation results: #{results.length}"
    results.each do |result|
      pp result
    end
  rescue ValidatorClient::ApiError => e
    puts "Exception when calling ValidationApi->get_validators: #{e}"
  end
end

all_apis.each { |api| try_validate(api) }
