require 'yaml'
require 'zk'
require 'pp'
require 'timeout'
require 'tiller/datasource'

class ZookeeperDataSource < Tiller::DataSource

  def setup
    # Set our defaults if not specified
    @zk_config = Tiller::Zookeeper::Defaults

    raise 'No zookeeper configuration block' unless Tiller::config.has_key?('zookeeper')
    @zk_config.merge!(Tiller::config['zookeeper'])

    # Sanity check
    ['uri'].each {|c| raise "Missing Zookeeper configuration #{c}" unless @zk_config.has_key?(c)}

    uri = @zk_config['uri']
    timeout = @zk_config['timeout']

    begin
      @zk = Timeout::timeout(timeout) { ZK.new(uri) }
    rescue
      raise "Could not connect to Zookeeper cluster : #{uri}"
    end

  end

  def values(template_name)
    path = @zk_config['values']['template']
      .gsub('%e',Tiller::config[:environment])
      .gsub('%t',template_name)

    get_values(path)
  end

  def global_values
    path = @zk_config['values']['global'].gsub('%e',Tiller::config[:environment])
    Tiller::log.info("Fetching Zookeeper globals from #{path}")
    get_values(path)
  end

  def target_values(template_name)
    path = @zk_config['values']['target']
      .gsub('%e',Tiller::config[:environment])
      .gsub('%t',template_name)
    get_values(path)
  end

  # Helper method, not used by DataSource API
  def get_values(path)
    values = {}
    if @zk.exists?(path)
      keys = @zk.children(path)
      keys.each do |key|
        value =  @zk.get("#{path}/#{key}")
        values[key] = value[0]
      end
    end
    values
  end

end
