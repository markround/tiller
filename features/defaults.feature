Feature: Defaults module
  Scenario: Load fixture
    Given I use a fixture named "defaults" 
    Then  a file named "environments/production.yaml" should exist

  Scenario: Data from defaults.yaml
    Given I use a fixture named "defaults" 
    When I successfully run `tiller -b . -v -e production -n`
    Then a file named "app.conf" should exist
    And the file "app.conf" should contain:
"""
[http]
http.port=8080
http.hostname=production.example.com

[smtp]
mail_domain_name=example.com

[db]
db.host=prd-db-1.example.com
"""

  Scenario: Override defaults
    Given I use a fixture named "defaults" 
    When I successfully run `tiller -b . -v -e override -n`
    Then a file named "app.conf" should exist
    And the file "app.conf" should contain:
"""
[http]
http.port=8081
http.hostname=override.example.com

[smtp]
mail_domain_name=example.com

[db]
db.host=stg-db-1.dev.example.com
"""

  Scenario: Use defaults.d directory
    Given I use a fixture named "defaults"
    When I successfully run `tiller -b . -v -e defaults_d -n`
    Then a file named "defaults_d.txt" should exist
    And the file "defaults_d.txt" should contain "This is a default from defaults.d"


  Scenario: Load target_values fixture
    Given I use a fixture named "defaults_targets"
    Then  a file named "environments/production.yaml" should exist

  Scenario: Data from defaults.yaml
    Given I use a fixture named "defaults_targets"
    When I successfully run `tiller -b . -v -e production -n`
    Then a file named "app.conf" should exist
    And a file named "target.txt" should exist
    And the file "app.conf" should contain:
    """
[http]
http.port=8080
http.hostname=production.example.com

[smtp]
mail_domain_name=example.com

[db]
db.host=prd-db-1.example.com
"""

  Scenario: Override defaults
    Given I use a fixture named "defaults_targets"
    When I successfully run `tiller -b . -v -e override -n`
    Then a file named "app.conf" should exist
    And a file named "target.txt" should exist
    And the file "app.conf" should contain:
    """
[http]
http.port=8081
http.hostname=override.example.com

[smtp]
mail_domain_name=example.com

[db]
db.host=stg-db-1.dev.example.com
"""

  Scenario: Check that target.txt is created
   Given I use a fixture named "defaults_targets"
   When I successfully run `tiller -b . -v -e production -n`
   Then a file named "target.txt" should exist
   And the file "target.txt" should contain "This is a value from defaults.yaml"


  # Not strictly a feature, but previous versions of Tiller didn't throw an error when we had an empty
  # template config definition in a defaults file. Tiller 0.7.3 "broke" this, so while it's arguably the
  # correct thing to bail out, in the interests of backwards-compatibility, we now instead log a warning and continue.
  Scenario: Check that empty defaults are handled
    Given I use a fixture named "empty_defaults"
    When I successfully run `tiller -b . -v -e -n`
    Then a file named "application.properties" should exist
    And the file "application.properties" should contain "app.text=This is application.properties"