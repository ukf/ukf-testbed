# frozen_string_literal: true

require 'testing'

def try_validate(endpoint)
  puts "\nPoking #{endpoint.name}..."
  metadata = IO.read 'tests/test_validate_bad.xml'
  begin
    results = endpoint.api.validate('default', metadata)
    puts "Validation results: #{results.length}"
    results.each do |result|
      pp result
    end
  rescue ValidatorClient::ApiError => e
    puts "Exception when calling ValidationApi->get_validators: #{e}"
  end
end

Testing.all_endpoints.each { |endpoint| try_validate(endpoint) }
