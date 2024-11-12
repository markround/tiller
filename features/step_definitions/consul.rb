require 'open-uri'
require 'diplomat'
require 'pp'
require 'openssl'

CONSUL_DATA_DIR="/tmp/tiller-consul-data"

# Consul configuration

Diplomat.configure do |config|
  config.url = "http://127.0.0.1:8500"
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
  hashicorp_download(uri, path)
end


Given(/^an empty consul data directory$/) do
  if Dir.exist?(CONSUL_DATA_DIR)
    puts "Directory #{CONSUL_DATA_DIR} exists, deleting"
    FileUtils.rm_r(CONSUL_DATA_DIR)
  else
    FileUtils.mkdir(CONSUL_DATA_DIR)
  end
end


Given(/^I have populated consul with test data$/) do
  populate_consul_test_data
end

Then (/^the consul key "(.+)" should exist$/) do |key|
  test = Diplomat::Kv.get(key)
  expect(test.size).to be > 0
end
