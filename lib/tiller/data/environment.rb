# Environment datasource for Tiller. This extracts all environment variables,
# and makes them available to templates by converting to lowercase and
# preceeding them with env_. E.G. env_home, env_logname and so on.
class EnvironmentDataSource < Tiller::DataSource
  def global_values
    values = Hash.new
    ENV.each { |k, v| values["env_#{k.downcase}"] = v }
    values
  end
end
