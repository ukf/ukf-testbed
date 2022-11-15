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

    #
    # Process the results of a validator invocation.
    #
    # If the actual results differ from what was expected,
    # call the handler using the passed context augmented with
    # details of the results in question.
    #
    def process_results(actual, expected, context)
      if actual == expected
        # log that they are the same
      else
        yield context.merge(problem: 'result mismatch',
                            actual: actual, expected: expected)
      end
    end

    def execute_validator(endpoint, validator, metadata, &handler)
      puts "Running #{@name} through #{validator} on #{endpoint.name}..."
      begin
        actual = results_to_array endpoint.api.validate(validator, metadata)
      rescue ValidatorClient::ApiError => e
        yield problem: "ApiError code #{e.code}",
              endpoint: endpoint.name, validator: validator, test: @name
        return
      end
      process_results actual, expected_results,
                      endpoint: endpoint.name, validator: validator, test: @name, &handler
    end

    def execute_one(endpoint, &handler)
      metadata = IO.read @xml_file
      validators.each { |validator| execute_validator(endpoint, validator, metadata, &handler) }
    end

    def execute(endpoints, &handler)
      endpoints.each { |endpoint| execute_one(endpoint, &handler) }
    end

    def self.find_all_tests
      Testbed.find_all_tests('xml', 'xml').map { |n| XMLTest.new(n) }
    end
  end
end
