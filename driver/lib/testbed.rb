# frozen_string_literal: true

require 'testbed/endpoint'
require 'testbed/xml_test'

#
# Module providing access to our testbed fleet of validators.
#
module Testbed
  #
  # Find all tests under a given prefix, by looking for files
  # with a given extension.
  #
  # Returns a list of test names, which is defined as the path
  # excluding the prefix and extension.
  #
  def self.find_all_tests(prefix, extension)
    head = "tests/#{prefix}/"
    hlen = head.length
    elen = extension.length
    Dir.glob("#{head}**/*.#{extension}").map { |s| s[hlen..-elen - 2] }
  end
end
