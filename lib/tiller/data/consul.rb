# encoding: utf-8
def plugin_meta
  {
      id: 'com.markround.tiller.data.consul',
      title: 'Consul',
      description: "These plugins allow you to retrieve your templates and values from a [Consul](https://consul.io) cluster. Full documentation for this plugin is available in [README-consul.md](README-consul.md), and there's also a blog post with a walk-through example at [http://www.markround.com/blog/2016/05/12/new-consul-plugin-for-tiller](http://www.markround.com/blog/2016/05/12/new-consul-plugin-for-tiller).",
      documentation: <<_END_DOCUMENTATION
# Consul plugins

As of version 0.7.8, Tiller includes plugins to retrieve templates, values, services and nodes from a [Consul](https://www.consul.io/) cluster. These plugins rely on the `diplomat` gem to be present, so before proceeding ensure you have run `gem install diplomat` in your environment. This is not listed as a hard dependency of Tiller, as this would force the gem to be installed even on systems that would never use these plugins.

# Enabling the plugins
Add the `consul` plugins in your `common.yaml`, e.g.

```yaml
data_sources: [ "consul" ]
template_sources: [ "consul" ]
```

If you're fetching all your values and templates from Consul, those should be the only plugins you need.

However, you do not need to enable both plugins; for example you may just want to retrieve values for your templates from consul, but continue to use files to store your actual template content. For example :

```yaml
data_sources: [ "consul", "environment" ]
template_sources: [ "file" ]
```

The above example would use templates from files, and retrieve values from Consul first, then try the `environment` plugin.


# Configuring
Configuration for this plugin is placed inside a "consul" block. This should be in the the top-level of `common.yaml` file, or in a per-environment block. See the main [README.md](https://github.com/markround/tiller/blob/master/README.md#common-configuration) for more information on this.

A sample configuration (showing the defaults for most parameters) is as follows :

```yaml
consul:
  uri: 'http://localhost:8500'
  dc: 'dc1'
  acl_token: <empty>
  register_services: false
  register_nodes: false

  templates: '/tiller/templates'
  values:
   global: '/tiller/globals/all'
   per_env: '/tiller/globals/%e'
   template: '/tiller/values/%e/%t'
   target: '/tiller/target_values/%t/%e'
```

At a bare minimum, you need to specify a URI for the plugins to connect to. This is the HTTP port of your Consul server, e.g. `http://localhost:8500`. If you omit the other parameters, they will default to the values shown above. If you're happy to accept the rest of the defaults, your configuration can therefore be as simple as this :

```yaml
data_sources: [ "consul" ]
template_sources: [ "consul" ]
consul:
  uri: 'http://localhost:8500'
```

## Authentication
If the Consul cluster you are connecting to requires a token, you can include `acl_token` in your configuration:

```yaml
consul:
  uri: 'http://localhost:8500'
  acl_token: '11210C70-B257-4534-9655-E7D8A2C1E660'
```

# Paths
You can use any K/V hierarchy inside Consul, but the default is expected to look like the following:

	/tiller
	 ├── globals
	 │   ├── all
	 │   │   └── some_key_for_all_environments
	 │   │
	 │   ├── production
	 │   │   └── some_key_only_for_production_environment
	 │   │
	 │   ... more environments here...
	 │
	 ├── templates (each key contains the ERB template as its value)
	 │   ├── template1.erb
	 │   ├── template2.erb
	 │   ... more templates here ...
	 │
	 ├── values
	 │   ├── production (keys and values for the 'production' environment)
	 │   │       ├ template1.erb
	 │   │       │     ├── some_key
	 │   │       │     ├── some_other_key
     │   │       ├ template2.erb
	 │   │       │     ├── some_key
	 │   │       │     ├── some_other_key
     │   │       ...more templates and keys...
 	 │   │
 	 │   └── development (keys and values for the 'development' environment)
	 │           ├ template1.erb
	 │           │     ├── some_key
	 │           │     ├── some_other_key
     │           ├ template2.erb
	 │           │     ├── some_key
	 │           │     ├── some_other_key
     │           ...more templates and keys...
 	 │
 	 │
     └── target_values (controls which templates get installed and where)
	     ├── template1.erb
	     │   ├── production
	     │   │       └── target (where to install the template in production)
	     │   └── development
	     │           └── target (where to install the template in development)
	     │
	     └── template1.erb (don't install template2.erb in development)
	         └── production
	                 └── target (where to install the template in production)



You can change this to any structure you like by altering the `templates` and `values` parameters. The paths specified for any of these parameters listed above may include the following placeholders :

* `%e` : This will be replaced with the value of the current environment
* `%t` : This will be replaced with the value of the current template

There is a benefit to keeping this default layout though: if you're using a shared Consul service, it makes it easy to define [ACLs](https://www.consul.io/docs/internals/acl.html) so that you can, for example, deny access to the `/values/production` or `/globals/production` paths for non-production services.

# Accessing data from templates

## K/V store
Consul keys and their values will be exposed to templates as regular variables. So, using the example structure above, you could just reference a consul key for your environment/template within your template like so :

```erb
This is a value for template1 : <%= some_key %>
This is a global value : <%= some_key_for_all_environments %>
This should only be present in production : <%= some_key_only_for_production_environment %>
```

## Nodes
To make the list of nodes registered with Consul available to your templates, set `register_nodes` to true in your `common.yaml` :

```yaml
data_sources: [ "consul" ]
template_sources: [ "consul" ]
consul:
  uri: 'http://localhost:8500'
  register_nodes: true
```

This will make a hash structure named `consul_nodes` available to your templates. This contains node_name => address key/value pairs. Within your ERB templates, you can access a specified node like so :

```erb
This is the address for node ccf95b08212d : <%= consul_nodes['ccf95b08212d'] %>
```

Or you can iterate over all nodes using standard Ruby constructs :

```erb
This is a list of all nodes :
<% consul_nodes.each do |node,address| -%>
  Node name : <%= node %> , Address : <%= address %>
<% end -%>
```

## Services
To make the list of services registered with Consul available to your templates, set `register_services` to true in your `common.yaml` :

```yaml
data_sources: [ "consul" ]
template_sources: [ "consul" ]
consul:
  uri: 'http://localhost:8500'
  register_services: true
```

This will make a hash structure named `consul_services` available to your templates. This has a service name as a key, and an array of nodes registered for that service as a value. These nodes are stored as [OpenStruct](http://ruby-doc.org/stdlib-1.9.3/libdoc/ostruct/rdoc/OpenStruct.html) structures. For example, within your ERB template, you can examine the details of the first registered instance of the `consul` service like so :

```erb
These are some details for the first registered instance of the consul service:
Node : <%= consul_services['consul'][0].Node %>
Address : <%= consul_services['consul'][0].Address %>
ServicePort : <%= consul_services['consul'][0].ServicePort %>
```

# Further reading
See [this](http://www.markround.com/blog/2016/05/12/new-consul-plugin-for-tiller) blog post for an introduction to this plugin with some examples.

_END_DOCUMENTATION
  }
end

require 'pp'
require 'diplomat'
require 'tiller/datasource'
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
    keys = Diplomat::Kv.get(path, { keys: true, :dc => @consul_config['dc'] }, :return)
    all_keys = {}
    if keys.is_a? Array
      keys.each do |k|
        @log.debug("#{self} : Fetching key #{k}")
        all_keys[File.basename(k)] = Diplomat::Kv.get(k, { nil_values: true, :dc => @consul_config['dc'] })
      end
      all_keys
    else
      {}
    end
  end

end
