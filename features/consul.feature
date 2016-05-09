Feature: Consul plugin

  Background:
    Given I use a fixture named "consul"

  Scenario: Download Consul
    When I have downloaded consul "0.6.4" to "/tmp/consul.zip"
    And I have unzipped the archive "/tmp/consul.zip"
    And I have made the file "/tmp/consul" executable"
    Then an absolute file named "/tmp/consul" should exist

  Scenario: Start consul daemon in stand-alone mode
    Given an empty consul data directory
    When I start my daemon with "/tmp/consul agent -server -bootstrap -client=0.0.0.0 -data-dir=/tmp/tiller-consul-data -advertise=127.0.0.1"
    Then a daemon called "consul" should be running
