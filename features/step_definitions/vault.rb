require 'open-uri'
require 'vault'
require 'pp'

# Vault configuration
VAULT_TOKEN_FILE = "#{Dir.home}/.vault-token"
# So that Cucumber does not complain that the file does not exist
File.open(VAULT_TOKEN_FILE, "w+"){|file| file.write(".")} if !File.exist? VAULT_TOKEN_FILE

Vault.configure do |config|
  config.address = "http://127.0.0.1:8200"
  config.token = File.read(VAULT_TOKEN_FILE)
end

When(/^I have downloaded vault "(.+)" to "(.+)"$/) do |version, path|
  if RUBY_PLATFORM =~ /darwin/
    uri = "https://releases.hashicorp.com/vault/#{version}/vault_#{version}_darwin_amd64.zip"
  elsif RUBY_PLATFORM =~ /linux/
    uri = "https://releases.hashicorp.com/vault/#{version}/vault_#{version}_linux_amd64.zip"
  else
    fail!("Unsupported platform for vault")
  end
  puts "Downloading #{uri}"

  hashicorp_download(uri, path)
end

And (/^a token should be created$/) do
  test = File.exist? VAULT_TOKEN_FILE
  expect(test).to be_truthy
end


Given(/^I have populated vault with test data$/) do
  Vault.configure do |config|
    config.address = "http://127.0.0.1:8200"
    config.token = File.read(VAULT_TOKEN_FILE)
  end
  populate_vault_test_data
end

Then (/^the vault key "(.+)" should exist$/) do |key|
  test = Vault.logical.read(key)
  expect(test.data).to be_truthy
end
