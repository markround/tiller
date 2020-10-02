# Created by dmarchewka at 07.06.18
Feature: Reusable template plugin
  This plugin allows users to reuse existing templates in different places with different data

  Scenario: Load fixture
    Given I use a fixture named "regex"
    Then  a file named "common.yaml" should exist

  Scenario: Create two configs from one template
    Given I use a fixture named "regex"
    When I successfully run `tiller -b . -v -n`
    Then a file named "temp.txt" should exist
    And the file "temp.txt" should contain exactly:
  """
Village did removed enjoyed explain nor ham saw calling talking.
Securing as freeinformed declared or margaret.
Joy horrible moreover man feelings own shy.
Request norland neither mistake for yet.
Between the for morning free assured country believe.
On even feet time have an no at.
Relation so in free smallest children unpacked delicate.
#some.comment
Why sir end believe uncivil respect.
#some.comment
Always get adieus nature day course for common.
My little garret repair to desire he esteem.
"""
  Scenario: Create two configs from one template
    Given I use a fixture named "regex"
    When I successfully run `tiller -b . -v -n`
    Then a file named "temp2.txt" should exist
    And the file "temp2.txt" should contain exactly:
"""
Before comment

    <Connector protocol="org.apache.coyote.http11.Http11NioProtocol"
 		port="8443" maxThreads="200"
 	</Connector>

After comment
"""
