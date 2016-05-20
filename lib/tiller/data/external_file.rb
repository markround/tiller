def plugin_meta
  {
      id: 'com.markround.tiller.data.external_file',
      title: 'External files',
      description: "Load external JSON or YAML files, and use their contents in your templates.",
      documentation: <<_END_DOCUMENTATION
# External File Plugin
This plugin lets you load an external JSON or YAML file, and return its contents to your templates as global values. You may find this useful for allowing an end user to configure a docker container which requires lots of parameters; thereby avoiding the need for lots of environment variables and unwieldy `docker run` commands.

The plugin is enabled by adding `external_file` to the list of datasources in your `common.yaml`, and then providing a list of absolute file paths :

```yaml
data_sources: [ "file" , "external_file" ]
external_files:
  - /config/external.yaml
  - /config/external.json
```

These could be provided by an end-user, and passed into the Docker container by way of volumes :

`docker run -ti -v /config:/config ......`

See the [test fixture](https://github.com/markround/tiller/tree/master/features/fixtures/external_file) for a full example.

_END_DOCUMENTATION
  }
end

require 'pp'
require 'yaml'
require 'json'
require 'tiller/util'

class ExternalFileDataSource < Tiller::DataSource

  def setup
    @merged_values = Hash.new
    if @config.has_key?('external_files')
      files = @config['external_files']
      files.each do |file|
        @merged_values.merge!(parse_file(file)) do |key, old, new|
          warn_merge(key, old, new, 'external file data', file)
        end
      end
    end
  end

  def global_values
    return @merged_values
  end

  def parse_file(filename)
    raise("External file '#{filename}' could not be loaded") unless File.file?(filename)
    @log.debug("#{self} : Loading #{filename}")
    parse = nil

    # First try to load it as JSON
    if ! parse
      begin
        parse = JSON.parse(File.read(filename))
        @log.debug("#{self} : #{filename} is in JSON format")
      rescue JSON::ParserError
      end
    end

    # Then YAML
    if ! parse
      begin
        parse = YAML.load(File.read(filename))
        @log.debug("#{self} : #{filename} is in YAML format")
      rescue Psych::SyntaxError
      end
    end

    # Unknown / unparsable format, bail out...
    if ! parse
      raise("External file '#{filename}' is in an unknown format")
    end

    return parse
  end

end

