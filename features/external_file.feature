Feature: Load data from external files

  Scenario: Load fixture
    Given I use a fixture named "external_file"
    Then  a file named "common.yaml" should exist
    
  Scenario: Simple data from external files
    Given I use a fixture named "external_file"
    When I successfully run `tiller -b . -v -n`
    Then the output should contain "external_key1 => 'From YAML' being replaced by : 'From JSON' from external.json"
    And a file named "template1.txt" should exist
    And the file "template1.txt" should contain:
  """
  Using data from external files
  Key 1 : From JSON
  Key 2 : From YAML
  Key 3 : From YAML
  """

