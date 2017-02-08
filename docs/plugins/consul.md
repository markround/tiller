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
Configuration for this plugin is placed inside a "consul" block. This should be in the the top-level of `common.yaml` file, or in a [per-environment block](file.md#overriding-common-settings).

A sample configuration (showing the defaults for most parameters) is as follows :

```yaml
consul:
  url: 'http://localhost:8500'
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

At a bare minimum, you need to specify a URL for the plugins to connect to. This is the HTTP port of your Consul server, e.g. `http://localhost:8500`. If you omit the other parameters, they will default to the values shown above. If you're happy to accept the rest of the defaults, your configuration can therefore be as simple as this :

```yaml
data_sources: [ "consul" ]
template_sources: [ "consul" ]
consul:
  url: 'http://localhost:8500'
```

## Authentication
If the Consul cluster you are connecting to requires a token, you can include `acl_token` in your configuration:

```yaml
consul:
  url: 'http://localhost:8500'
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
  url: 'http://localhost:8500'
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
  url: 'http://localhost:8500'
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
See [this](http://www.markround.com/blog/2016/05/12/new-consul-plugin-for-tiller) blog post for a walk-through tutorial with some examples.

