# frozen_string_literal: true

require 'testbed'

failures = []
endpoints = Testbed.all_endpoints
Testbed::XMLTest.find_all_tests.each do |test|
  test.execute(endpoints) do |problem|
    failures << problem
  end
end

unless failures.empty?
  puts 'Test failures were detected:'
  failures.each do |f|
    puts "*** #{f[:problem]} in #{f[:test]} on #{f[:endpoint]}'s #{f[:validator]} validator"
    if f[:problem] == 'result mismatch'
      puts '   expected result: '
      puts YAML.dump(f[:expected])
      puts '   actual result:'
      puts YAML.dump(f[:actual])
    end
    puts
  end
end
