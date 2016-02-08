Feature: Exit status codes
  Scenario: Load fixture
    Given I use a fixture named "defaults"
    Then  a file named "environments/production.yaml" should exist

  Scenario: Return true
    Given I use a fixture named "defaults"
    When I successfully run `tiller -b . -v -e production -x true`
    Then the exit status should be 0
    And the output should contain "Child process exited with status 0"


  Scenario: Return false
    Given I use a fixture named "defaults"
    When I run `tiller -b . -v -e production -x false`
    Then the exit status should be 1
    And the output should contain "Child process exited with status 1"


