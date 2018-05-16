class RegexTemplateSource < Tiller::TemplateSource

  def initialize
    super
    @template_dir = File.join(Tiller::config[:tiller_base], 'templates/')
  end

  def setup
    @config_hash = Hash.new

    if Tiller::config.has_key?('defaults')
      Tiller::log.debug("#{self} : Loading defaults from Tiller::config")
      @config_hash.deep_merge!(Tiller::config['defaults'])
      Tiller::log.debug("Config default: #{@config_hash}")
    end

    if Tiller::config.has_key?('environments')
      Tiller::log.debug("Tryting to merge in config for environment")
      if Tiller::config['environments'].has_key?(Tiller::config[:environment])
        Tiller::log.debug("#{self} : Using values from v2 format common.yaml")
        if Tiller::config['environments'][Tiller::config[:environment]].is_a? Hash
          @config_hash.deep_merge!(Tiller::config['environments'][Tiller::config[:environment]])
          Tiller::log.debug("Config enviroment: #{@config_hash}")
        end
      end
    end
  end

  def templates
    @config_hash.keys.grep(/\!regex/).each {|item|
      template(item)
    }
    return []
  end

  def template(template_name)
    template_org = @config_hash[template_name]['target']
    content = open(template_org).read
    @config_hash[template_name]['regex'].each{ |item|
      content.gsub!(item['find'], item['replace'])
    }
    target = open(template_org, 'w')
    target.puts(content)
    target.close
  end

end
