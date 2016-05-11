#!/usr/bin/env ruby

require 'diplomat'
require 'pp'

def populate_consul_test_data
  Diplomat.configure do |config|
    config.url = "http://localhost:8500"
  end

  # Template contents
  template1 = %{This is template1.
This is a value from Consul : <%= consul_value %>
This is a global value from Consul : <%= consul_global %>
This is a per-environment global : <%= consul_per_env %>}
  template2 = %{This is template2.
This is a value from Consul : <%= consul_value %>
This is a global value from Consul : <%= consul_global %>
This is a per-environment global : <%= consul_per_env %>}

  # Populate globals
  Diplomat::Kv.put('tiller/globals/all/consul_global', 'consul global value')
  # Populate per-environment globals
  Diplomat::Kv.put('tiller/globals/development/per_env', 'per-env global for development enviroment')
  Diplomat::Kv.put('tiller/globals/production/per_env', 'per-env global for production enviroment')
  # Populate template values
  Diplomat::Kv.put('tiller/templates/template1.erb/values/consul_value', 'value from consul for template1.erb')
  Diplomat::Kv.put('tiller/templates/template1.erb/values/per_env', 'This is over-written for template1')
  Diplomat::Kv.put('tiller/templates/template2.erb/values/consul_value', 'value from consul for template2.erb')
  # Populate templates
  Diplomat::Kv.put('tiller/templates/template1.erb/content', template1)
  Diplomat::Kv.put('tiller/templates/template2.erb/content', template2)
end

if ! defined?(Cucumber)
  puts "Running from shell"
  populate_consul_test_data
end