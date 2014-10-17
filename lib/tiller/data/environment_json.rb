# Environment JSON datasource for Tiller. This extracts all JSON from the
# tiller_json environment variable and merges the resulting hash data
# structure into the global_values available to templates.

require 'json'
require 'pp'

class EnvironmentJsonDataSource < Tiller::DataSource
  def global_values

    if ENV.has_key?('tiller_json')
      begin
        json_structure = JSON.parse(ENV['tiller_json'])
        json_structure if json_structure.is_a?(Hash)
      rescue JSON::ParserError
        puts "Warning : Error parsing tiller_json environment variable"
        Hash.new
      end
    else
      Hash.new
    end

  end
end
