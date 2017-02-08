# Main configuration values
  
`common.yaml` contains most of the configuration for Tiller. It contains top-level `exec`, `data_sources`, `template_sources` and `default_environment` parameters, along with sections for each environment. 
  
It can also take optional blocks of configuration for some plugins (for example, the [Consul Plugins](../plugins/consul.md)). Settings defined here can also be overridden on a per-environment basis.
  
## exec  
This is simply what will be executed after the configuration files have been generated. If you omit this (or use the `-n` / `--no-exec` arguments) then no child process will be executed. You should specify the command and arguments as an array, e.g.
  
```yaml
  exec: [ "/usr/bin/supervisord" , "-n" ]
```
  
This means that a shell will not be spawned to run the command, and no shell expansion will take place. This is the preferred form, as it means that signals should propagate properly through to spawned processes. However, you can still use the old style string parameter, e.g.

```yaml
  exec: "/usr/bin/supervisord -n"
```
  
## data_sources

This parameter specifies the data source plugins you'll be using to populate the configuration files. This should usually just be set to "file" to start with, although there are a lot of [bundled plugins](../plugins/index.md) provided. You can also [write your own plugins](../developers.md) and pull them in. These plugins are provided as a YAML array, for example:

```yaml
data_sources: [ "file" , "consul" , "environment"]
```

Or in the long-form:

```yaml
data_sources:
  - file
  - consul
  - environment
```


## template_sources
This parameter specifies which plugin will be providing the templates. It uses the same array syntax as `data_sources`:

```yaml
template_sources: [ "file" ]
```
  

## default_environment

This parameter sets the default environment to  use if one is not specified (either using the -e flag, or via the `environment` environment variable). This defaults to 'development'.

```yaml
default_environment: testing
```

# Example
For a simple use-case where you're just generating everything from files and then spawning MongoDB with a different replica set name specified in the staging and production environments, you'd have a common.yaml like this:

```yaml
---
exec: [ "/usr/bin/mongod" , "--config" , "/etc/mongodb.conf" , "--rest" ]
data_sources: [ 'file' ]
template_sources: [ 'file' ]
environments:

	staging:
		mongodb.erb:
  			target: /etc/mongodb.conf
  			user: root
  			group: root
  			perms: 0644
			config:
				replSet: 'staging'

	production:
		mongodb.erb:
  			target: /etc/mongodb.conf
 			config:
    			replSet: 'production'
    			
	development:
		mongodb.erb:
  			target: /etc/mongodb.conf
```

And a mongodb.erb template that contained:

```erb
...
... rest of file snipped
...
<% if (replSet) -%>
replSet = <%= replSet %>
<% end -%> 
```