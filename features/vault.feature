Feature: Vault plugin

  Scenario: Download Vault
    When I have downloaded vault "0.6.1" to "/tmp/vault.zip"
    And I have unzipped the archive "/tmp/vault.zip"
    And I have made the file "/tmp/vault" executable"
    Then an absolute file named "/tmp/vault" should exist

  Scenario: Start vault daemon in development mode
    When I start my daemon with "/tmp/vault server -dev"
    Then a daemon called "vault" should be running
    And a token should be created

  Scenario: Populate vault with test data
    Given I have populated vault with test data
    Then the vault key "secret/tiller/globals/all/vault_global" should exist


  Scenario: Test dev environment template generation with Vault
    Given I use a fixture named "vault"
    When I successfully run `tiller -b . -v -n`
    Then a file named "template1.txt" should exist
    And the file "template1.txt" should contain:
    """
    This is template1.
    This is a value from Vault : development value from Vault for template1.erb
    This is a global value from Vault : Vault global value
    This is a per-environment global : This is over-written for template1 in development
    """
    And a file named "template2.txt" should exist
    And the file "template2.txt" should contain:
    """
    This is template2.
    This is a value from Vault : development value from Vault for template2.erb
    This is a global value from Vault : Vault global value
    This is a per-environment global : per-env global for development enviroment
    """

  Scenario: Test prod environment template generation with Vault
    Given I use a fixture named "vault"
    When I successfully run `tiller -b . -v -n -e production`
    Then a file named "template1.txt" should exist
    And the file "template1.txt" should contain:
    """
    This is template1.
    This is a value from Vault : production value from Vault for template1.erb
    This is a global value from Vault : Vault global value
    This is a per-environment global : per-env global for production enviroment
    """
    And a file named "template2.txt" should not exist

  Scenario: Test environment without Vault block
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["true"]
    data_sources: [ "vault" , "file" ]
    template_sources: [ "vault" , "file" ]

    environments:
      development:
        test.erb:
          target: test.txt
          config:
            test_var: "This is a template var from the development env"
    """
    And a directory named "templates"
    And a file named "templates/test.erb" with:
    """
    test_var: <%= test_var %>
    """
    When I successfully run `tiller -b . -v -n -e development`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    test_var: This is a template var from the development env
    """
    And the output should contain "No Vault configuration block for this environment"