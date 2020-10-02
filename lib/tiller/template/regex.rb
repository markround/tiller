require 'pathname'

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
    template_org = Pathname.new(@config_hash[template_name]['target'])
    template_absolute = template_org
    if !template_absolute.absolute?
      template_absolute = Pathname.pwd().join(template_org)
    end
    content = open(template_absolute).read
    @config_hash[template_name]['regex'].each{ |item|
      replace = String.new(item['replace'])
      find = String.new(item['find'])
      if find.start_with?('/')
        find = eval(item['find'])
      end
      content.gsub!(find, replace)
    }
    target = open(template_absolute, 'w')
    target.puts(content)
    target.close
  end

end
