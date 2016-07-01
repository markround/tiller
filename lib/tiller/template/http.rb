require 'pp'
require 'httpclient'
require 'timeout'
require 'tiller/http.rb'



class HttpTemplateSource < Tiller::TemplateSource

  include Tiller::HttpCommon

  def templates
    parse(get_uri(@http_config['uri'] + @http_config['templates']))
  end

  def template(template_name)
    get_uri(@http_config['uri'] + @http_config['template_content'], :template => template_name)
  end

end
