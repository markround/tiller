# File plugins

These plugins are usually required and should be enabled unless you are providing *all* other configuration and templates through a plugin such as [consul](consul.md) or [zookeeper](zookeeper.md). This is because Tiller uses the File plugins to parse much of the `common.yaml` configuration, and read .erb templates from the filesystem.

## Template source plugin

When using the `file` plugin in the list provided to the `template_sources` parameter, files under `/etc/tiller/templates` are made available. 

These files are the ERb templates for your configuration files, and are populated with values from data source plugins, including the `file` plugin which provides values from the rest of `common.yaml` and is [covered below](#data-source-plugin).

**IMPORTANT: ** These files must be named with a suffix of `.erb`. Any files without an ending of `.erb` will be ignored.


## Data source plugin

When using the `file` plugin in the list provided to the `data_sources` parameter, the rest of the `common.yaml` configuration file is parsed for additional values, environment definitions, lists of templates to be generated and so on.

### Environment configuration
When you're using this plugin, environment blocks (underneath the `environments:` key in `common.yaml`) define the templates to be parsed, where the generated configuration file should be installed, ownership and permission information, and also optionally a set of key:value pairs (the "template values") that are made available to the template via the usual `<%= key %>` ERB syntax.

These blocks in `common.yaml` are named after the environment variable `environment` that you pass in (usually by using `docker run -e environment=<whatever>`, which sets the environment variable). If you are not using Tiller inside a Docker container, you can set the environment by using the `tiller -e` flag from the command line. 

#### Example

As an example, again using MongoDB example, here's how you might set the replica set name in your staging and production environments:

```yaml
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
```

Note that if you omit the user/group/perms parameters - as shown above for the production environment - the defaults are whatever Docker runs as (usually root). Also, if you don't run Tiller as root, it will skip setting these.

Of course, this means you need an environment block for each replica set you plan on deploying. If you have many Mongo clusters you wish to deploy, you'll probably want to specify the replica set name dynamically, perhaps at the time you launch the container. You can do this in many different ways, for example by using the [environment](environment.md) plugin to populate values from environment variables (`docker run -e repl_set_name=foo ...`) and so on. 


### Overriding common settings
You can also override defaults from common.yaml if you specify them in a `common` block in an environment section. This means you can specify a different `exec`, enable the API, or configure various plugins to use different settings on a per-environment basis, e.g.

```yaml
environments:

	development:
		
		# Only enable API for development environment, and
		# also specify HTTP plugin values	
		common:
		  api_enable: true
		  api_port: 1234
		  
		  # configuration for HTTP plugin (https://github.com/markround/tiller/blob/master/README-HTTP.md)
		  http:
		    uri: 'http://tiller.dev.example.com'
		    ...
		    ...
		    ... rest of config file snipped
		    ...
		    ...
```

