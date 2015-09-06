require 'yaml'
# Defaults datasource for Tiller.

# Thanks, StackOverflow ;)
class ::Hash
  def deep_merge!(second)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
    self.merge!(second, &merger)
  end
end


class DefaultsDataSource < Tiller::DataSource
  def setup
    defaults_file = File.join(@config[:tiller_base], 'defaults.yaml')
    defaults_dir  = File.join(@config[:tiller_base], 'defaults.d')
    @defaults_hash = Hash.new

    # First, try and load defaults from v2 config
    if @config.has_key?('defaults')
      @log.debug("#{self} : Using values from v2 format common.yaml")
      @defaults_hash.deep_merge!(@config['defaults'])
    else
      # Read defaults in from defaults file if no v2 config
      # Handle empty files - if YAML didn't parse, it returns false so we skip them
      if File.file? defaults_file
        yaml = YAML.load(open(defaults_file))
        @defaults_hash.deep_merge!(yaml) if yaml != false
      end
    end

    # If we have YAML files in defaults.d, also merge them
    # We do this even if the main defaults were loaded from the v2 format config
    if File.directory? defaults_dir
      Dir.glob(File.join(defaults_dir,'*.yaml')).each do |d|
        yaml = YAML.load(open(d))
        @log.debug("Loading defaults from #{d}")
        @defaults_hash.deep_merge!(yaml) if yaml != false
      end
    end
  end

  def global_values
    @defaults_hash.key?('global') ? @defaults_hash['global'] : Hash.new
  end

  def values(template_name)
    @defaults_hash.key?(template_name) ? @defaults_hash[template_name] : Hash.new
  end

end
