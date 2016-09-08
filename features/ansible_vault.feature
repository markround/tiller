Feature: Ansible vault
  Background:
  Given a file named "vault.yml.enc" with:
    """
    $ANSIBLE_VAULT;1.1;AES256
    30613762363462363266336137376631653334373132653462303332663539623638643863633363
    3363323632353566333131346537313163306239656437330a373036653331613630306135613630
    36393834646634393138373862323033396332646331633534316534616162336138343662393635
    3433663165613334390a303164613730386366393364333361336265653531353936353261663835
    39356133323166623062653135313539326361393737396134633031626133336633633261306438
    33366635333061626131336462656361313734313536613666366430653339653536643038363330
    38363535353836613534633135656532313263613931613834333330383635313435373339383831
    62663762303763383561
    """
  And a directory named "templates"
  And a file named "templates/test.erb" with:
    """
    Test var : <%= test_var %>
    Test hash: <%= test_hash %>
    """
  And a directory named "lib/tiller/helper"

  @ruby21
  Scenario: Vault with env var
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["cat","test.txt"]
    data_sources: [ "file" , "ansible_vault"]
    template_sources: [ "file" ]
    ansible_vault:
      vault_file: vault.yml.enc
    environments:
      development:
        test.erb:
          target: test.txt
    """
    And I set the environment variables exactly to:
      | variable            | value   |
      | ANSIBLE_VAULT_PASS  | tiller  |
    When I successfully run `tiller -b . -n -v -d`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    Test var : Var from Ansible Vault
    Test hash: {"key"=>"Hash from Ansible Vault"}
    """
    And the output should contain:
    """
    Using password from environment variable ANSIBLE_VAULT_PASS
    """

  @ruby21
  Scenario: Vault with different env var
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["cat","test.txt"]
    data_sources: [ "file" , "ansible_vault"]
    template_sources: [ "file" ]
    ansible_vault:
      vault_file: vault.yml.enc
      vault_password_env: MY_PASSWORD
    environments:
      development:
        test.erb:
          target: test.txt
    """
    And I set the environment variables exactly to:
      | variable     | value   |
      | MY_PASSWORD  | tiller  |
    When I successfully run `tiller -b . -n -v -d`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    Test var : Var from Ansible Vault
    Test hash: {"key"=>"Hash from Ansible Vault"}
    """
    And the output should contain:
    """
    Using password from environment variable MY_PASSWORD
    """

  @ruby21
  Scenario: Vault with password from configuration
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["cat","test.txt"]
    data_sources: [ "file" , "ansible_vault"]
    template_sources: [ "file" ]
    ansible_vault:
      vault_file: vault.yml.enc
      vault_password: tiller
    environments:
      development:
        test.erb:
          target: test.txt
    """
    When I successfully run `tiller -b . -n -v -d`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    Test var : Var from Ansible Vault
    Test hash: {"key"=>"Hash from Ansible Vault"}
    """
    And the output should contain:
    """
    Using password from configuration block
    """

  @ruby21
  Scenario: Vault with password from file
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["cat","test.txt"]
    data_sources: [ "file" , "ansible_vault"]
    template_sources: [ "file" ]
    ansible_vault:
      vault_file: vault.yml.enc
      vault_password_file: password.txt
    environments:
      development:
        test.erb:
          target: test.txt
    """
    And a file named "password.txt" with "tiller"
    When I successfully run `tiller -b . -n -v -d`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    Test var : Var from Ansible Vault
    Test hash: {"key"=>"Hash from Ansible Vault"}
    """
    And the output should contain:
    """
    Using password from file
    """

  @ruby21
  Scenario: No config for environment
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["cat","test.txt"]
    data_sources: [ "file" , "ansible_vault"]
    template_sources: [ "file" ]
    environments:
      development:
        test.erb:
          target: test.txt
          config:
            test_var: From file data source
    """
    When I successfully run `tiller -b . -n -v -d`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    Test var : From file data source
    """
    And the output should contain:
    """
    No Ansible vault configuration block for this environment
    """

  @ruby21
  Scenario: Config in environment common block
    Given a file named "common.yaml" with:
    """
    ---
    exec: ["cat","test.txt"]
    data_sources: [ "file" , "ansible_vault"]
    template_sources: [ "file" ]
    environments:
      development:
        common:
          ansible_vault:
            vault_file: vault.yml.enc
            vault_password: tiller
        test.erb:
          target: test.txt
    """
    When I successfully run `tiller -b . -n -v -d`
    Then a file named "test.txt" should exist
    And the file "test.txt" should contain:
    """
    Test var : Var from Ansible Vault
    Test hash: {"key"=>"Hash from Ansible Vault"}
    """
    And the output should contain:
    """
    Using password from configuration block
    """
