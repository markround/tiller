#!/usr/bin/env ruby

require 'vault'
require 'pp'

def populate_vault_test_data(url='http://127.0.0.1:8200')
  Vault.configure do |config|
    config.address = url
  end

  # Template contents
  template1 = %{This is template1.
This is a value from Vault : <%= vault_value %>
This is a global value from Vault : <%= vault_global %>
This is a per-environment global : <%= vault_per_env %>}

  template2 = %{This is template2.
This is a value from Vault : <%= vault_value %>
This is a global value from Vault : <%= vault_global %>
This is a per-environment global : <%= vault_per_env %>}


  # Populate globals
  Vault.logical.write('/secret/tiller/globals/all/vault_global', content: 'Vault global value')
  # Populate per-environment globals
  Vault.logical.write('/secret/tiller/globals/development/vault_per_env', content: 'per-env global for development enviroment')
  Vault.logical.write('/secret/tiller/globals/production/vault_per_env', content: 'per-env global for production enviroment')
  # Populate template values for development environment
  Vault.logical.write('/secret/tiller/values/development/template1.erb/vault_value', content: 'development value from Vault for template1.erb')
  Vault.logical.write('/secret/tiller/values/development/template1.erb/vault_per_env', content: 'This is over-written for template1 in development')
  Vault.logical.write('/secret/tiller/values/development/template2.erb/vault_value', content: 'development value from Vault for template2.erb')
  # Populate template values for production environment
  Vault.logical.write('/secret/tiller/values/production/template1.erb/vault_value', content: 'production value from Vault for template1.erb')
  Vault.logical.write('/secret/tiller/values/production/template2.erb/vault_value', content: 'production value from Vault for template2.erb')
  # Populate target_values for environments
  Vault.logical.write('/secret/tiller/target_values/template1.erb/development/target', content: 'template1.txt')
  Vault.logical.write('/secret/tiller/target_values/template2.erb/development/target', content: 'template2.txt')
  # No template 2 for production
  Vault.logical.write('/secret/tiller/target_values/template1.erb/production/target', content: 'template1.txt')
  # Populate templates content
  Vault.logical.write('/secret/tiller/templates/template1.erb', content: template1)
  Vault.logical.write('/secret/tiller/templates/template2.erb', content: template2)
end

if ! defined?(Cucumber)
  url = ARGV[0] ? ARGV[0] : "http://127.0.0.1:8200"
  puts "Populating Vault at #{url} with test data"
  populate_vault_test_data(url)
end
