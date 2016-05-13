require 'pp'
require 'diplomat'
require 'tiller/consul.rb'

class ConsulTemplateSource < Tiller::TemplateSource

  include Tiller::ConsulCommon

  def templates
    path = interpolate("#{@consul_config['templates']}")
    @log.debug("#{self} : Fetching templates from #{path}")
    templates = Diplomat::Kv.get(path, {:keys => true}, :return)

    if templates.is_a? Array
      templates.map{|t| File.basename(t)}
    else
      @log.warn("Consul : No templates could be fetched from #{path}")
      []
    end
  end

  def template(template_name)
    path = interpolate("#{@consul_config['templates']}")
    Diplomat::Kv.get("#{path}/#{template_name}")
  end

end
