#!/usr/bin/env ruby

require 'diplomat'
require 'pp'

def populate_consul_test_data(url="http://127.0.0.1:8500")
  Diplomat.configure do |config|
    config.url = url
  end

  # Template contents
  template1 = %{This is template1.
This is a value from Consul : <%= consul_value %>
This is a global value from Consul : <%= consul_global %>
This is a per-environment global : <%= consul_per_env %>
If we have enabled node and service registration, these follow.
Nodes : <%= consul_nodes %>
Services : <%= consul_services %>}

  template2 = %{This is template2.
This is a value from Consul : <%= consul_value %>
This is a global value from Consul : <%= consul_global %>
This is a per-environment global : <%= consul_per_env %>}

  # Populate globals
  Diplomat::Kv.put('tiller/globals/all/consul_global', 'consul global value')
  # Populate per-environment globals
  Diplomat::Kv.put('tiller/globals/development/consul_per_env', 'per-env global for development enviroment')
  Diplomat::Kv.put('tiller/globals/production/consul_per_env', 'per-env global for production enviroment')
  # Populate template values for development environment
  Diplomat::Kv.put('tiller/values/development/template1.erb/consul_value', 'development value from consul for template1.erb')
  Diplomat::Kv.put('tiller/values/development/template1.erb/consul_per_env', 'This is over-written for template1 in development')
  Diplomat::Kv.put('tiller/values/development/template2.erb/consul_value', 'development value from consul for template2.erb')
  # Populate template values for production environment
  Diplomat::Kv.put('tiller/values/production/template1.erb/consul_value', 'production value from consul for template1.erb')
  Diplomat::Kv.put('tiller/values/production/template2.erb/consul_value', 'production value from consul for template2.erb')
  # Populate target_values for environments
  Diplomat::Kv.put('tiller/target_values/template1.erb/development/target', 'template1.txt')
  Diplomat::Kv.put('tiller/target_values/template2.erb/development/target', 'template2.txt')
  # No template 2 for production
  Diplomat::Kv.put('tiller/target_values/template1.erb/production/target', 'template1.txt')
  # Populate templates content
  Diplomat::Kv.put('tiller/templates/template1.erb', template1)
  Diplomat::Kv.put('tiller/templates/template2.erb', template2)
end

if ! defined?(Cucumber)
  url = ARGV[0] ? ARGV[0] : "http://localhost:8500"
  puts "Populating Consul at #{url} with test data"
  populate_consul_test_data(url)
end