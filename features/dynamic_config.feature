Feature: Dynamic configuration

  Background:
    Given a directory named "lib/tiller/helper"
    And a file named "lib/tiller/helper/test.rb" with:
    """
    module Tiller::TestHelper
      def self.test
        "Test string"
      end
    end
    """

  Scenario: Test dynamic configuration
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
    When I successfully run `tiller -vd -b . -l ./lib`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "dynamic_value: Test string"
    And the output should contain "Dynamic configuration specified. Re-parsing values as ERb"
    And the output should contain "Found ERb syntax"

  Scenario: Test dynamic configuration with nested hash
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
            root_hash:
              nested_hash:
                dynamic_value: <%= Tiller::TestHelper.test %>
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    dynamic_value: <%= root_hash['nested_hash']['dynamic_value'] %>
    """
    When I successfully run `tiller -vd -b . -l ./lib`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "dynamic_value: Test string"
    And the output should contain "Dynamic configuration specified. Re-parsing values as ERb"
    And the output should contain "Found ERb syntax"

  Scenario: Test dynamic configuration with datasource values
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "cat" , "test.txt" ]
    data_sources: [ "environment" , "file" ]
    template_sources: [ "file" ]
    helpers: [ "test" ]
    dynamic_config: true

    environments:
      development:
        test.erb:
          target: test.txt
          config:
            dynamic_value: <%= env_dynamic_value %>
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    dynamic_value: <%= dynamic_value %>
    """
    And I set the environment variables exactly to:
      | variable          | value       |
      | dynamic_value     | Test string |
    When I successfully run `tiller -vd -b . -l ./lib`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "dynamic_value: Test string"
    And the output should contain "Dynamic configuration specified. Re-parsing values as ERb"
    And the output should contain "Found ERb syntax"

  Scenario: Test dynamic target from environment
    Given a file named "common.yaml" with:
    """
    ---
    exec: [ "cat" , "dynamic.txt" ]
    data_sources: [ "environment" , "file" ]
    template_sources: [ "file" ]
    helpers: [ "test" ]
    dynamic_config: true

    environments:
      development:
        test.erb:
          target: <%= env_dynamic_target %>
          config:
            dynamic_value: <%= env_dynamic_value %>
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    dynamic_value: <%= dynamic_value %>
    """
    And I set the environment variables exactly to:
      | variable          | value       |
      | dynamic_value     | Test string |
      | dynamic_target    | dynamic.txt |
    When I successfully run `tiller -vd -b . -l ./lib`
    Then a file named "dynamic.txt" should exist
    And the file "dynamic.txt" should contain "dynamic_value: Test string"
    And the output should contain "Dynamic configuration specified. Re-parsing values as ERb"
    And the output should contain "Found ERb syntax"
