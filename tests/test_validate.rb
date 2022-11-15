# frozen_string_literal: true

require 'testbed'

failures = []
endpoints = Testbed.all_endpoints
Testbed::XMLTest.find_all_tests.each do |test|
  test.execute(endpoints)
rescue ValidatorClient::ApiError => e
  puts "Exception when executing #{test.name}: #{e.code} #{e}"
  failures << "API code #{e.code}"
rescue StandardError => e
  puts "StandardError raised when executing #{test.name}: #{e}"
  failures << e
end

unless failures.empty?
  puts 'Test failures were detected:'
  failures.each do |f|
    puts "   #{f}"
  end
end
