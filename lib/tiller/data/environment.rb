require 'tiller/datasource'

class EnvironmentDataSource < Tiller::DataSource
  def global_values
    values = Hash.new
    ENV.each { |k, v| values["env_#{k.downcase}"] = v }
    values
  end
end
