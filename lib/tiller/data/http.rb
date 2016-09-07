require 'pp'
require 'httpclient'
require 'timeout'
require 'tiller/http.rb'
require 'tiller/datasource'


class HttpDataSource < Tiller::DataSource

  include Tiller::HttpCommon

  def values(template_name)
    return {} unless Tiller::config.has_key?('http')
    parse(get_uri(@http_config['uri'] + @http_config['values']['template'], :template => template_name))
  end

  def global_values
    return {} unless Tiller::config.has_key?('http')
    parse(get_uri(@http_config['uri'] + @http_config['values']['global']))
  end

  def target_values(template_name)
    return {} unless Tiller::config.has_key?('http')
    parse(get_uri(@http_config['uri'] + @http_config['values']['target'], :template => template_name))
  end

end
