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

    #
    # Process the sidecar file containing the test's options.
    # If the file doesn't exist, the options are empty.
    #
    def process_options
      yaml_file = test_file('yaml')
      @options = if File.file?(yaml_file)
                   YAML.load_file(yaml_file)
                 else
                   {}
                 end
    end

    #
    # Find overrides for a given endpoint if they exist.
    #
    def overrides_for(endpoint)
      puts "looking for overrides for endpoint #{endpoint.name}"
      (@options['override'] || []).select do |ovr|
        Array(ovr['endpoint']).include?(endpoint.name)
      end
    end

    #
    # Returns the array of validators to execute for a given endpoint. The
    # validators either come from the global (to all endpoints) set,
    # the default set defined, or from any matching endpoint override.
    #
    # A single endpoint can have more than one override each with it's own
    # set of validators and it's own set of expected statuses.
    #
    # The returned Array contains the names of validators to run for the given
    # endpoint, and for each, its corresponding override block.
    #
    def validator_executions(endpoint)
      
      ovs = overrides_for(endpoint)
      puts "Found overrides #{ovs}"
      executions = []
      # Add executions for each validator in the override(s) for the endpoint
      ovs.each do |ovr|
        Array(ovr['validators']).each do |v|
          executions << { validator: v, override: ovr }
        end
      end
      # If no overrides defined validators, fall back to the top‑level or default
      if executions.empty?
        default_vals = @options['validators'] ||
                      ['default', 'edugain', 'publication', 'registered_entity']
        default_vals.each do |v|
          executions << { validator: v, override: nil }
        end
      end
      puts "Found validators for overrides #{executions}"
      executions
    end

    #
    # Return the array of statuses that are expected by this test, either from
    # the endpoint override configuration, or the top level (global to all endpoints) 
    # configuration. The override input is expected to be about the correct endpoint.
    #
    # The default is none.
    #
    def expected_option(override)
      if override && override.key?('expected')
        override['expected']
      else
        @options['expected'] || []
      end
    end

    #
    # Check the override indicating whether this test should be skipped.
    # If not in the endpoint override options, check for a top level override.
    #
    def skip_option(override)
      if override && override.key?('skip')
        override['skip']
      else
        @options['skip'] || false
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

    #
    # Execute the validator inside the execution array. Each validator
    # is accopmanied by its override config for the given endpoint. 
    #
    def execute_validator(endpoint, execution, metadata, &handler)
      puts "Running execution #{execution}"
      # Validators and overrides should be for the given endpoint already
      validator = execution[:validator]
      override  = execution[:override]

      # Silently skip this execution if the skip option is present
      return if skip_option(override)

      puts "Running #{@name} through #{validator} on #{endpoint.name}..."
      begin
        actual = results_to_array endpoint.api.validate(validator, metadata)
      rescue ValidatorClient::ApiError => e
        yield problem: "ApiError code #{e.code}: #{e.response_body}",
              endpoint: endpoint.name, validator: validator, test: @name
        return
      end

      process_results actual, expected_option(override),
                      endpoint: endpoint.name, validator: validator, test: @name, &handler
    end

    #
    # Execute each of the validators defined for the endpoint. Validators are
    # taken either from the top level set of global (to all endpoint) validators, 
    # the default set of global (to all endpoint) validators, or those in overrides 
    # defined per endpoint.
    #
    def execute_one(endpoint, &handler)
      metadata = IO.read @xml_file
      validator_executions(endpoint).each { |execution| execute_validator(endpoint, execution, metadata, &handler) }
    end

    # Execute each of the defined endpoints.
    def execute(endpoints, &handler)
      endpoints.each { |endpoint| execute_one(endpoint, &handler) }
    end

    def self.find_all_tests
      Testbed.find_all_tests('xml', 'xml').map { |n| XMLTest.new(n) }
    end
  end
end
