Feature: Configure tiller with nested environment variables

  Scenario: Import environment variable using string data type
    Given I use a fixture named "environment_nested"
    And I set the environment variables to:
      | variable      | value                      |
      | my_nested_var | http://www.somecompany.com |
    When I successfully run `tiller -b . -v -n`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "test_var: http://www.somecompany.com"

  Scenario: Import environment variable using numeric data type
    Given I use a fixture named "environment_nested"
    And I set the environment variables to:
      | variable      | value      |
      | my_nested_var | 1234       |
    When I successfully run `tiller -b . -v -n`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "test_var: 1234"

  Scenario: Import environment variable using boolean data type
    Given I use a fixture named "environment_nested"
    And I set the environment variables to:
      | variable      | value      |
      | my_nested_var | true       |
    When I successfully run `tiller -b . -v -n`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "test_var: true"

