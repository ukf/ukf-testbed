# frozen_string_literal: true

require 'testing'

def try_validate(endpoint, test_name)
  puts "\nRunning #{test_name} on #{endpoint.name}..."
  metadata = IO.read "tests/xml/#{test_name}.xml"
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

Testing.find_all_tests('xml', 'xml').each do |test_name|
  Testing.all_endpoints.each { |endpoint| try_validate(endpoint, test_name) }
end
