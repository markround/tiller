Feature: Miscellaneous bug fixes

  Scenario: Load duplicate_values fixture
    Given I use a fixture named "duplicate_values"
    Then  a file named "common.yaml" should exist

  Scenario: Ensure values do not merge
    Given I use a fixture named "duplicate_values"
    When I successfully run `tiller -b . -v -n`
    Then a file named "test1.txt" should exist
    And the file "test1.txt" should contain "This is test1.txt"
    Then a file named "test2.txt" should exist
    And the file "test2.txt" should contain "This is test2.txt"
    And the output should not contain "merging"
