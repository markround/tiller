def plugin_meta
  {
      id: 'com.markround.tiller.data.environment_json',
      title: 'JSON environment variables',
      description: "Use complex JSON data structures from the environment in your templates. See [http://www.markround.com/blog/2014/10/17/building-dynamic-docker-images-with-json-and-tiller-0-dot-1-4/](http://www.markround.com/blog/2014/10/17/building-dynamic-docker-images-with-json-and-tiller-0-dot-1-4/) for some practical examples.",
      documentation: <<_END_DOCUMENTATION
# Environment JSON Plugin
If you add `  - environment_json` to your list of data sources in `common.yaml`, you'll be able to make complex JSON data structures available to your templates. Just pass your JSON in the environment variable `tiller_json`. See [http://www.markround.com/blog/2014/10/17/building-dynamic-docker-images-with-json-and-tiller-0-dot-1-4/](http://www.markround.com/blog/2014/10/17/building-dynamic-docker-images-with-json-and-tiller-0-dot-1-4/) for some practical examples.

As of Tiller 0.7.6, you can use this to also handle per-template variables, instead of treating everything as a "global" variable. To do this, make sure you have a key `_version` with a value of `2`. You can then separate values into global and per-template blocks, for example :

```json
{
  "_version" : 2,
  "global" : {
    "global_value" : "This is a global value available to all templates"
  },
  "template.erb" : {
    "local_value" : "This will create the 'local_value' only on template.erb"
  }
}
```

_END_DOCUMENTATION
  }
end

require 'tiller/datasource'
require 'json'
require 'pp'

class EnvironmentJsonDataSource < Tiller::DataSource

  VERSION_KEY='_version'

  def setup
    if ENV.has_key?('tiller_json')
      begin
        parse = JSON.parse(ENV['tiller_json'])
        @json_structure = parse.is_a?(Hash) ? parse : Hash.new
        if @json_structure[VERSION_KEY].is_a? Integer
          @json_version = @json_structure[VERSION_KEY]
          @log.debug("Using v#{@json_version} tiller_json format")
        else
          @json_version = 1
        end
      rescue JSON::ParserError
        @log.warn('Warning : Error parsing tiller_json environment variable')
      end
    else
      @json_structure = Hash.new
    end
  end

  def global_values
    if @json_version < 2
      @json_structure
    else
      if @json_structure.has_key?('global')
        @json_structure['global']
      else
        Hash.new
      end
    end
  end

  def values(template_name)
    if @json_version < 2
      return Hash.new
    end

    if @json_structure.has_key?(template_name)
      return @json_structure[template_name]
    else
      return Hash.new
    end
  end

end
