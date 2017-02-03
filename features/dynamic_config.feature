Feature: Dynamic configuration

  Background:
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "cat" , "test.txt" ]
    data_sources: [ "file" ]
    template_sources: [ "file" ]
    helpers: [ "test" ]
    dynamic_config: true

    environments:
      development:
        test.erb:
          target: test.txt
          config:
            dynamic_value: <%= Tiller::TestHelper.test %>
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    dynamic_value: <%= dynamic_value %>
    """
    And a directory named "lib/tiller/helper"
    And a file named "lib/tiller/helper/test.rb" with:
    """
    module Tiller::TestHelper
      def self.test
        "Test string"
      end
    end
    """

  Scenario: Test dynamic configuration
    When I successfully run `tiller -vd -b . -l ./lib`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "dynamic_value: Test string"
    And the output should contain "Dynamic configuration specified. Re-parsing as ERb"
    And the output should contain "Found ERb syntax"

