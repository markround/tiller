def plugin_meta
  {
      id: 'com.markround.tiller.plugin.template.zookeeper',
      documentation_link: 'com.markround.tiller.data.zookeeper'
  }
end

require 'tiller/templatesource'

class ZookeeperTemplateSource < Tiller::TemplateSource

  def setup
    # Set our defaults if not specified
    @zk_config = Tiller::Zookeeper::Defaults

    raise 'No zookeeper configuration block' unless @config.has_key?('zookeeper')
    @zk_config.merge!(@config['zookeeper'])

    # Sanity check
    ['uri'].each {|c| raise "Missing Zookeeper configuration #{c}" unless @zk_config.has_key?(c)}

    uri = @zk_config['uri']
    timeout = @zk_config['timeout']

    begin
      @zk = Timeout::timeout(timeout) { ZK.new(uri) }
    rescue
      raise "Could not connect to Zookeeper cluster : #{uri}"
    end

  end

  def templates
    path = @zk_config['templates'].gsub('%e',@config[:environment])
    @log.info("Fetching Zookeeper templates from #{path}")
    templates = []
    if @zk.exists?(path)
      templates = @zk.children(path)
    end

    templates
  end

  def template(template_name)
    path = @zk_config['templates'].gsub('%e',@config[:environment]) + "/#{template_name}"
    @zk.get(path)[0]
  end


end
