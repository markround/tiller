require 'open-uri'
require 'pp'

CONSUL_DATA_DIR="/tmp/tiller-consul-data"

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
