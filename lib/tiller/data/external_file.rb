require 'pp'
require 'yaml'
require 'json'
require 'tiller/util'

class ExternalFileDataSource < Tiller::DataSource

  def setup
    @merged_values = Hash.new
    if Tiller::config.has_key?('external_files')
      files = Tiller::config['external_files']
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
    Tiller::log.debug("#{self} : Loading #{filename}")
    parse = nil

    # First try to load it as JSON
    if ! parse
      begin
        parse = JSON.parse(File.read(filename))
        Tiller::log.debug("#{self} : #{filename} is in JSON format")
      rescue JSON::ParserError
      end
    end

    # Then YAML
    if ! parse
      begin
        parse = YAML.load(File.read(filename))
        Tiller::log.debug("#{self} : #{filename} is in YAML format")
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

