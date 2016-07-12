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
