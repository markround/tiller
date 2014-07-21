# File datasource for Tiller. This works the same way as the default behaviour in Runner.rb - it loads your
# <environment>.yaml file and provides data from it. See examples/etc/tiller/environments/production.yaml to see
# what this file looks like.

require 'yaml'

class FileDataSource < Tiller::DataSource

  # We don't provide any global values, just ones specific to a template.
  def initialize(config)
    super
    env_file = File.join(@@config[:tiller_base], "environments", "#{@@config[:environment]}.yaml")
    @config_hash = YAML::load(open(env_file))
  end

  def values(template_name)
    @config_hash.has_key?(template_name) ? @config_hash[template_name]['config'] : Hash.new
  end

  def target_values(template_name)
    @config_hash.has_key?(template_name) ? @config_hash[template_name] : Hash.new
  end

end
