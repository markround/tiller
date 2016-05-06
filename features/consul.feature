Feature: Consul plugin

  Scenario: Download Consul
    Given I use a fixture named "consul"
    And I have downloaded consul "0.6.4" to "consul.zip"
    Then a file named "consul.zip" should exist
