require 'tiller/datasource'

class EnvironmentNestedDataSource < Tiller::DataSource

  def global_values
    values = Hash.new
    ENV.each do |k, v|
      begin
        v = YAML.load(v)  # helper to get real data type instead of string
        values.deep_merge!(k.split('_').reverse.inject(v) { |a, n| { n => a } })
      rescue
        Tiller::log.debug("Environment variable #{k} with value #{v} could not be unfolded (ignored)")
      end
    end
    values
  end

end
