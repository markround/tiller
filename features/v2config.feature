Feature: Tiller v2 config

  Scenario: Load fixture
    Given I use a fixture named "single_file"
    Then  a file named "common.yaml" should exist

  Scenario: Test for v2 message when debug passed
    Given I use a fixture named "single_file"
    When I successfully run `tiller -b . -d -v -n`
    Then the output should contain "Using common.yaml v2 format configuration file"

  Scenario: Test loading missing environment
    Given I use a fixture named "single_file"
    When I run `tiller -b . -d -v -n -e parp`
    Then the output should contain "Error : Could not load environment parp from common.yaml"

  Scenario: Test with development environment
    Given I use a fixture named "single_file"
    When I successfully run `tiller -b . -d -v -n`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    Test value : This value came from a single config file
    Default value : This is a default value
    Defaults.d value: Value from defaults.d
    """

  Scenario: Test with production environment
    Given I use a fixture named "single_file"
    When I successfully run `tiller -b . -d -v -n -e production`
    Then the output should contain "default_value => 'This is a default value' being replaced by : 'This is a default value, overwritten from the template config' from FileDataSource"
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    Test value : This is again a value from a single config file, this time the production environment.
    Default value : This is a default value, overwritten from the template config
    Defaults.d value: Value from defaults.d
    """