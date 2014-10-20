require 'yaml'
# File datasource for Tiller. This works the same way as the default behaviour
# in Runner.rb - it loads your <environment>.yaml file and pulls data from it.
# See examples/etc/tiller/environments/production.yaml to see what this file
# looks like.
#
# We also don't provide any global values, just ones specific to a template.
class FileDataSource < Tiller::DataSource
  # Open and parse the environment file
  def setup
    env_file = File.join(@config[:tiller_base], 'environments',
                         "#{@config[:environment]}.yaml")
    @config_hash = YAML.load(open(env_file))
  end

  def values(template_name)
    @config_hash.key?(template_name) ? @config_hash[template_name]['config'] : Hash.new
  end

  def target_values(template_name)
    # The config element is redundant (not a target value)
    @config_hash.key?(template_name) ? @config_hash[template_name] : Hash.new
  end
end
