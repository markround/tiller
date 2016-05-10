require 'open-uri'
require 'diplomat'
require 'pp'

CONSUL_DATA_DIR="/tmp/tiller-consul-data"

# Consul configuration

Diplomat.configure do |config|
  config.url = "http://localhost:8500"
end


When(/^I have downloaded consul "(.+)" to "(.+)"$/) do |version, path|
  if RUBY_PLATFORM =~ /darwin/
    uri = "https://releases.hashicorp.com/consul/#{version}/consul_#{version}_darwin_amd64.zip"
  elsif RUBY_PLATFORM =~ /linux/
    uri = "https://releases.hashicorp.com/consul/#{version}/consul_#{version}_linux_amd64.zip"
  else
    fail!("Unsupported platform for consul")
  end
  puts "Downloading #{uri}"

  download = open(uri)
  IO.copy_stream(download, path)
end


Given(/^an empty consul data directory$/) do
  if Dir.exists?(CONSUL_DATA_DIR)
    puts "Directory #{CONSUL_DATA_DIR} exists, deleting"
    FileUtils.rm_r(CONSUL_DATA_DIR)
  else
    FileUtils.mkdir(CONSUL_DATA_DIR)
  end
end

Given(/^I have populated consul with test data$/) do
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

Then (/^the consul key "(.+)" should exist$/) do |key|
  test = Diplomat::Kv.get(key)
  expect(test.size).to be > 0
end