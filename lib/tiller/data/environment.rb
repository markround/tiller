# Environment datasource for Tiller. This extracts all environment variables, and makes them available to templates
# by converting to lowercase and preceeding them with env_. E.G. env_home, env_logname and so on.

class EnvironmentDataSource < Tiller::DataSource

  def global_values
    ENV.each { |k,v| @global_values["env_#{k.downcase}"] = v }
    @global_values
  end

end
