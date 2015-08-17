Feature: Tiller environment plugin

  Scenario: Load fixture
    Given I use a fixture named "environment_plugin"
    Then  a file named "environments/development.yaml" should exist

  Scenario: Simple data from environment
    Given I use a fixture named "environment_plugin"
    Given I set the environment variables exactly to:
      | variable    | value           |
      | test        | Hello, World!   |
    When I successfully run `tiller -b . -v -n`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "Hello, World!"

  Scenario: Local config overrides global plugin
    Given I use a fixture named "environment_plugin"
    Given I set the environment variables exactly to:
      | variable    | value           |
      | test        | Hello, World!   |
    When I successfully run `tiller -b . -v -n -e local_override`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "This value overwrites the global value provided by the environment plugin"

