require 'open-uri'
require 'pp'

When(/^I have downloaded consul "(.+)" to "(.+)"$/) do |version, path|
  if RUBY_PLATFORM =~ /darwin/
    uri = "https://releases.hashicorp.com/consul/#{version}/consul_#{version}_darwin_386.zip"
  elsif RUBY_PLATFORM =~ /linux/
    uri = "https://releases.hashicorp.com/consul/#{version}/consul_#{version}_darwin_386.zip"
  else
    fail!("Unsupported platform for consul")
  end
  puts "Downloading #{uri}"

  download = open(uri)
  IO.copy_stream(download, expand_path(path))
end
