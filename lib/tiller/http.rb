# Common methods for HTTP plugins

require 'httpclient'
require 'timeout'
require 'pp'
require 'tiller/defaults.rb'
require 'json'

module Tiller::HttpCommon

  def setup
    # Set our defaults if not specified
    @http_config = Tiller::Http::Defaults

    raise 'No HTTP configuration block' unless @config.has_key?('http')
    @http_config.merge!(@config['http'])

    # Sanity check
    ['uri'].each {|c| raise "HTTP: Missing HTTP configuration #{c}" unless @http_config.has_key?(c)}

    # Create the client used for all requests
    @client = HTTPClient.new(@http_config['proxy'])

    # Basic auth for resource
    if @http_config.has_key?('username')
      @log.debug('HTTP: Using basic authentication')
      raise 'HTTP: Missing password for authentication' unless @http_config.has_key?('password')
      @client.set_auth(nil, @http_config['username'], @http_config['password'])
    end

    # Basic auth for proxy
    if @http_config.has_key?('proxy_username')
      @log.debug('HTTP: Using proxy basic authentication')
      raise 'HTTP: Missing password for proxy authentication' unless @http_config.has_key?('proxy_password')
      @client.set_proxy_auth(@http_config['proxy_username'], @http_config['proxy_password'])
    end
  end


  # Interpolate the placeholders and return content from a URI
  def get_uri(uri, interpolate={})
    uri.gsub!('%e', @config[:environment])
    uri.gsub!('%t', interpolate[:template]) if interpolate[:template]

    @log.debug("HTTP: Fetching #{uri}")
    resp = @client.get(uri, :follow_redirect => true)
    raise "HTTP: Server responded with status #{resp.status} for #{uri}" if resp.status != 200
    resp.body
  end


  # Wrap parsing here, so we can implement XML and other parsers later
  def parse(content)
    case @http_config['parser']
      when 'json'
        @log.debug("HTTP: Using JSON parser")
        JSON.parse(content)
      else
        raise "HTTP: Unsupported parser '#{@http_config['parser']}'"
    end
  end


end