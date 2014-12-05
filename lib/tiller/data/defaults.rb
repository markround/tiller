require 'yaml'
require 'pp'
# Defaults datasource for Tiller.

class ::Hash
  def deep_merge!(second)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
    self.merge!(second, &merger)
  end
end


class DefaultsDataSource < Tiller::DataSource
  # Open and parse the environment file
  def setup
    defaults_file = File.join(@config[:tiller_base], 'defaults.yaml')
    defaults_dir  = File.join(@config[:tiller_base], 'defaults.d')
    @defaults_hash = Hash.new

    # Read defaults in from defaults file
    if File.file? defaults_file
      @defaults_hash.deep_merge!(YAML.load(open(defaults_file)))
    end

    # If we have YAML files in defaults.d, also merge them
    if File.directory? defaults_dir
      Dir.glob(File.join(defaults_dir,'*.yaml')).each do |d|
        @defaults_hash.deep_merge!(YAML.load(open(d)))
      end
    end
  end

  def global_values
    @defaults_hash.key?('global') ? @defaults_hash['global'] : Hash.new
  end

  def values(template_name)
    @defaults_hash.key?(template_name) ? @defaults_hash[template_name] : Hash.new
  end

end
