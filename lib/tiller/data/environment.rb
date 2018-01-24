require 'tiller/datasource'

class EnvironmentDataSource < Tiller::DataSource

  @plugin_api_versions = [ 1, 2 ]

  def setup
    @plugin_config = Tiller::Environment.defaults
    if Tiller::config.has_key? 'environment' and Tiller::config['environment'].is_a? Hash
      @plugin_config.merge!(Tiller::config['environment'])
    end
  end


  def global_values
    values = Hash.new
    if @plugin_config['lowercase']
      ENV.each { |k, v| values["#{@plugin_config['prefix']}#{k.downcase}"] = v }
    else
      ENV.each { |k, v| values["#{@plugin_config['prefix']}#{k}"] = v }
    end
    values
  end
end
