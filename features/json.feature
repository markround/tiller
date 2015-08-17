Feature: JSON environment data source
  Scenario: Load fixture
    Given I use a fixture named "json"
    Then  a file named "environments/array.yaml" should exist

  Scenario: Set environment variable
    Given I set the environment variables exactly to:
      | variable           | value      |
      | tiller_json        | '{ "key" : "value" }' |
    When I run `env`
    Then the output should contain "tiller_json"

  Scenario: Simple data from environment
    Given I use a fixture named "json"
    Given I set the environment variables exactly to:
      | variable    | value                                                                      |
      | tiller_json | { "default_value" : "from JSON!" , "key1" : "value1" , "key2" : "value2" } |
    When I successfully run `tiller -b . -v -n -e simple_keys`
    Then a file named "simple_keys.txt" should exist
    And the file "simple_keys.txt" should contain:
"""
Default value : This overrides the global value from the JSON data source

 * Key 1 is : value1
 * Key 2 is : value2
"""


  Scenario: Array data from environment
    Given I use a fixture named "json"
    Given I set the environment variables exactly to:
      | variable    | value                                                                      |
      | tiller_json | { "servers" : [ "server1" , "server2" , "server3" ] } |
    When I successfully run `tiller -b . -v -n -e array`
    Then a file named "array.txt" should exist
    And the file "array.txt" should contain:
"""
This is a list of all servers:

    Server : server1
    Server : server2
    Server : server3
"""

  Scenario: Override defaults from environment
    Given I use a fixture named "json"
    Given I set the environment variables exactly to:
      | variable    | value                                                                      |
      | tiller_json | { "default_value" : "from JSON!" , "key1" : "value1" , "key2" : "value2" } |
    When I successfully run `tiller -b . -v -n -e override`
    Then a file named "simple_keys.txt" should exist
    And the file "simple_keys.txt" should contain "from JSON!"
