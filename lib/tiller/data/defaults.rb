def plugin_meta
  {
      id: 'com.markround.tiller.data.defaults',
      title: 'Defaults',
      description: "Make use of default values across your environments and templates - this can help avoid repeated definitions and makes for more efficient configuration.",
      documentation: <<_END_DOCUMENTATION
# Defaults Plugin
If you add `  - defaults` to your list of data sources in `common.yaml`, you'll be able to make use of default values for your templates, which can save a lot of repeated definitions if you have a lot of common values shared between environments. You can also (as of Tiller 0.7.3) use it to install a template across all environments.

These defaults are sourced from a `defaults:` block in your `common.yaml`, or from `/etc/tiller/defaults.yaml` if you are using the old-style configuration. For both styles, any individual `.yaml` files under `/etc/tiller/defaults.d/` are also loaded and parsed.

Top-level configuration keys are `global` for values available to all templates, and a template name for values only available to that specific template. For example, in your `common.yaml` you could add something like:

```yaml
data_sources: [ 'defaults' , 'file' , 'environment' ]
defaults:

	global:
  		domain_name: 'example.com'

	application.properties.erb:
	    target: /etc/application.properties
	    config:
  		    java_version: 'jdk8'
```

This would make the variable `domain_name` available to all templates, and would also ensure that the `application.properties.erb` template gets installed across all environments.

## Defaults per environment

As of Tiller 0.7.7, you can also use the file datasource to specify a top-level `global_values:` key inside each environment block to specify global values unique to that environment. See [issue #18](https://github.com/markround/tiller/issues/18) for the details.

This means you can (optionally) use the defaults datasource to specify a default across _all_ environments, `global_values:` for defaults specific to each environment, and optionally over-write them with local `config:` values on each template. Something like this :

```
data_sources: [ 'defaults','file','environment' ]
template_sources: [ 'file' ]

defaults:
  global:
    per_env: 'This is the default across all environments'

environments:

  development:
    global_values:
      per_env: 'This has been overwritten for the development environment'

    test.erb:
      target: test.txt
      config:
        per_env: 'This has again been overwritten by the local value just for this template'

  production:

	# This will get the value from the defaults module, as we don't specify a
	# per-environment or any per-template value overwriting it.
    test.erb:
      target: test.txt

```

_END_DOCUMENTATION
  }
end


require 'yaml'
require 'tiller/util'
require 'tiller/datasource'

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
