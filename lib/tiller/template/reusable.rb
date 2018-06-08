class ReusableTemplateSource < Tiller::TemplateSource

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
    @config_hash.keys.grep(/erb\!\w+/)
  end

  def template(template_name)
    template_org = String.new(template_name).sub!(/!.*/,'')
    open(File.join(@template_dir, template_org)).read
  end

end
