require 'pp'
require 'diplomat'
require 'tiller/consul.rb'

class ConsulDataSource < Tiller::DataSource

  include Tiller::ConsulCommon

  def global_values
    # Fetch globals
    path = interpolate("#{@consul_config['values']['global']}")
    @log.debug("#{self} : Fetching globals from #{path}")
    globals = fetch_all_keys(path)

    # Do we have per-env globals ? If so, merge them
    path = interpolate("#{@consul_config['values']['per_env']}")
    @log.debug("#{self} : Fetching per-environment globals from #{path}")
    globals.deep_merge!(fetch_all_keys(path))

    # Do we want to register services in consul_services hash ?
    if @consul_config['register_services']
      @log.debug("#{self} : Registering Consul services")
      globals['consul_services'] = {}
      services = Diplomat::Service.get_all({ :dc => @consul_config['dc'] })
      services.marshal_dump.each do |service, _data|
        @log.debug("#{self} : Fetching Consul service information for #{service}")
        service_data = Diplomat::Service.get(service, :all, { :dc => @consul_config['dc']})
        globals['consul_services'].merge!( { "#{service}" => service_data })
      end
    end

    # Do we want to register nodes in consul_nodes hash ?
    if @consul_config['register_nodes']
      @log.debug("#{self} : Registering Consul nodes")
      globals['consul_nodes'] = {}
      nodes = Diplomat::Node.get_all
      nodes.each do |n|
        globals['consul_nodes'].merge!({ n.Node => n.Address })
      end
    end
    globals
  end

  def values(template_name)
    path = interpolate("#{@consul_config['values']['template']}", template_name)
    @log.debug("#{self} : Fetching template values from #{path}")
    fetch_all_keys(path)
  end

  def target_values(template_name)
    path = interpolate("#{@consul_config['values']['target']}", template_name)
    @log.debug("#{self} : Fetching template target values from #{path}")
    fetch_all_keys(path)
  end


  def fetch_all_keys(path)
    keys = Diplomat::Kv.get(path, { keys: true }, :return)
    all_keys = {}
    if keys.is_a? Array
      keys.each do |k|
        @log.debug("#{self} : Fetching key #{k}")
        all_keys[File.basename(k)] = Diplomat::Kv.get(k, { nil_values: true })
      end
      all_keys
    else
      {}
    end
  end

end
