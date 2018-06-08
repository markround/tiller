# Created by dmarchewka at 07.06.18
Feature: Reusable template plugin
  This plugin allows users to reuse existing templates in different places with different data

  Scenario: Load fixture
    Given I use a fixture named "reusable"
    Then  a file named "scenario1/common.yaml" should exist

  Scenario: Create two configs from one template
    Given I use a fixture named "reusable"
    When I successfully run `tiller -b ./scenario1 -v -n`
    Then a file named "temp.txt" should exist
    And the file "temp.txt" should contain:
  """
  Test file: temp origin
  """
    And a file named "temp1.txt" should exist
    And the file "temp1.txt" should contain:
  """
  Test file: temp1
  """
    And a file named "temp2.txt" should exist
    And the file "temp2.txt" should contain:
  """
  Test file: temp2
  """
    And a file named "temp3.txt" does not exist

  Scenario: Create two configs from one template using default configuration
    Given I use a fixture named "reusable"
    When I successfully run `tiller -b ./scenario2 -v -n`
    Then a file named "default.txt" should exist
    And the file "default.txt" should contain:
  """
  Test file: default origin
  """
    And a file named "default1.txt" should exist
    And the file "default1.txt" should contain:
  """
  Test file: default1
  """
    And a file named "default2.txt" should exist
    And the file "default2.txt" should contain:
  """
  Test file: default2
  """

  Scenario: Trying to use deep_merge with default configuration
    Given I use a fixture named "reusable"
    When I successfully run `tiller -b ./scenario3 -v -n`
    Then a file named "default.txt" should exist
    And the file "default.txt" should contain:
  """
  Test file: default origin
  """
    And a file named "default1.txt" should exist
    And the file "default1.txt" should contain:
  """
  Test file: default1
  """
    And a file named "default2.txt" should exist
    And the file "default2.txt" should contain:
  """
  Test file: default2
  """