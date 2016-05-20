def plugin_meta
  {
      id: 'com.markround.tiller.plugin.template.consul',
      documentation_link: 'com.markround.tiller.data.consul'
  }
end

require 'pp'
require 'diplomat'
require 'tiller/templatesource'
require 'tiller/consul.rb'

class ConsulTemplateSource < Tiller::TemplateSource

  include Tiller::ConsulCommon

  def templates
    path = interpolate("#{@consul_config['templates']}")
    @log.debug("#{self} : Fetching templates from #{path}")
    templates = Diplomat::Kv.get(path, {:keys => true, :dc => @consul_config['dc']}, :return)

    if templates.is_a? Array
      templates.map { |t| File.basename(t) }
    else
      @log.warn("Consul : No templates could be fetched from #{path}")
      []
    end
  end

  def template(template_name)
    path = interpolate("#{@consul_config['templates']}")
    Diplomat::Kv.get("#{path}/#{template_name}", {:dc => @consul_config['dc']})
  end

end
