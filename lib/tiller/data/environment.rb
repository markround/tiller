def plugin_meta
  {
      id: 'com.markround.tiller.data.environment',
      title: 'Environment variables',
      description: "Make use of environment variables in your templates.",
      documentation: <<_END_DOCUMENTATION
# Environment Plugin
If you activated the `EnvironmentDataSource` (as shown by adding `  - environment` to the list of data sources in the example `common.yaml` above), you'll also be able to access environment variables within your templates. These are all converted to lower-case, and prefixed with `env_`. So for example, if you had the environment variable `LOGNAME` set, you could reference this in your template with `<%= env_logname %>`

_END_DOCUMENTATION
  }
end

require 'tiller/datasource'

class EnvironmentDataSource < Tiller::DataSource
  def global_values
    values = Hash.new
    ENV.each { |k, v| values["env_#{k.downcase}"] = v }
    values
  end
end
