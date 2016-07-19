require 'tiller/datasource'

class EnvironmentDataSource < Tiller::DataSource

  def setup
    @plugin_config = Tiller::Environment.defaults
    if @config.has_key? 'environment' and @config['environment'].is_a? Hash
      @plugin_config.merge!(@config['environment'])
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
