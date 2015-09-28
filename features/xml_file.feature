Feature: xml_file config

  Scenario: Load fixture
    Given I use a fixture named "xml_file"
    Then  a file named "common.yaml" should exist

  Scenario: Test global XML parsing
    Given I use a fixture named "xml_file"
    When I successfully run `tiller -b . -d -v -n -e global`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "ArtifactID: my-app"

  Scenario: Test per-template XML parsing
    Given I use a fixture named "xml_file"
    When I successfully run `tiller -b . -d -v -n -e template`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain "ArtifactID: my-app-template"

  Scenario: Test missing XML file
    Given I use a fixture named "xml_file"
    When I run `tiller -b . -d -v -n -e broken`
    Then a file named "test.txt" should not exist
    And the output should contain "Error : Could not parse XML file pom-nonexist.xml"