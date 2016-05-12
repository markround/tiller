require 'yaml'
require 'tiller/util'

# Defaults datasource for Tiller.

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
    # Backwards compatibility stuff here. This datasource didn't use to return target_values, so
    # all values were just stored as top-level keys instead of under a separate config: block
    # If a config: block exists, we should use that in preference to the top-level keys, but
    # if not we still return them all so we don't break anything using the old behaviour.

    if @defaults_hash.key?(template_name)
      values = @defaults_hash[template_name]
      if values.is_a? Hash
        values.key?('config') ? values['config'] : values
      else
        # Previous versions of Tiller didn't throw an error when we had an empty
        # template config definition in a defaults file. Tiller 0.7.3 "broke" this, so while it's arguably the
        # correct thing to bail out, in the interests of backwards-compatibility, we now instead log a warning and continue.
        @log.warn("Warning, empty config for #{template_name}")
        Hash.new
      end
    else
      Hash.new
    end
  end

  def target_values(template_name)
    if @defaults_hash.key?(template_name)
      values = @defaults_hash[template_name]
      if values.is_a? Hash
        values.key?('target') ? values : Hash.new
      else
        # See comments for values function.
        @log.warn("Warning, empty config for #{template_name}")
        Hash.new
      end
    else
      Hash.new
    end
  end

end
