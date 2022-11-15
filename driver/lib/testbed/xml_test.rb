# frozen_string_literal: true

require 'yaml'

#
# Module providing access to our testbed fleet of validators.
#
module Testbed
  #
  # Representation of an individual XML test.
  #
  class XMLTest
    attr_reader :name

    def initialize(name)
      @name = name

      @xml_file = test_file('xml')
      raise "test file does not exist for #{@name}" unless File.file?(@xml_file)

      process_options
    end

    def process_options
      yaml_file = test_file('yaml')
      @options = if File.file?(yaml_file)
                   YAML.load_file(yaml_file)
                 else
                   {}
                 end
    end

    #
    # Returns the array of validators specified in the options file,
    # or a default.
    #
    def validators
      option = @options['validators'] || ['default']
      if option.is_a? Array
        option
      else
        [option]
      end
    end

    def test_file(extension)
      "tests/xml/#{@name}.#{extension}"
    end

    def results_to_array(results)
      results.map do |r|
        {
          'status' => r.status,
          'component_id' => r.component_id,
          'message' => r.message
        }
      end
    end

    #
    # Returns the array of statuses that are expected by this test.
    # By default, none.
    #
    def expected_results
      @options['expected'] || []
    end

    def process_results(actual, expected)
      if actual == expected
        # log that they are the same
      else
        puts 'Result mismatch; expected: '
        puts YAML.dump(expected)
        puts 'actual result:'
        puts YAML.dump(actual)
        raise StandardError, 'result mismatch'
      end
    end

    def execute_validator(endpoint, validator, metadata)
      puts "Running #{@name} through #{validator} on #{endpoint.name}..."
      results = results_to_array endpoint.api.validate(validator, metadata)
      process_results results, expected_results
    end

    def execute_one(endpoint)
      metadata = IO.read @xml_file
      validators.each { |validator| execute_validator(endpoint, validator, metadata) }
    end

    def execute(endpoints)
      endpoints.each { |endpoint| execute_one(endpoint) }
    end

    def self.find_all_tests
      Testbed.find_all_tests('xml', 'xml').map { |n| XMLTest.new(n) }
    end
  end
end
