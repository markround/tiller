# What is it?
Tiller is a tool that generates configuration files. It takes a set of templates, fills them in with values from a variety of sources (such as environment variables, Consul, YAML files, JSON from a webservice...), installs them in a specified location and then optionally spawns a child process.

You might find this particularly useful if you're using Docker, as you can ship a set of configuration files for different environments inside one container, and/or easily build "parameterized containers" which users can then configure at runtime. 

However, its use is not just limited to Docker; you may also find it useful as a sort of "proxy" that can provide values to application configuration files from a data source that the application does not natively support. 

It's available as a [Ruby Gem](https://rubygems.org/gems/tiller), so installation should be a simple `gem install tiller`.

[![Gem Version](https://badge.fury.io/rb/tiller.svg)](http://badge.fury.io/rb/tiller)
[![Build Status](https://travis-ci.org/markround/tiller.svg?branch=develop)](https://travis-ci.org/markround/tiller)
![](https://img.shields.io/gem/dt/tiller.svg)
 [![Join the chat at https://gitter.im/markround/tiller](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/markround/tiller)
[![Documentation Status](https://readthedocs.org/projects/tiller/badge/?version=latest)](http://tiller.readthedocs.io/en/latest/?badge=latest)

# Documentation
The main documentation has been updated and a searchable, easy to read version is now hosted on [readthedocs.io](http://tiller.readthedocs.io/). You can also read the raw markdown files by browsing the [docs](docs/) directory in this repository.





## Common configuration

### Complete example
I'll cover each part of this in detail, but to give you an idea of where we're going with this, here's the complete configuration file I discuss in the examples below :

```yaml
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
Note that instead of the YAML one-per-line list format for enabling plugins, I used the shorthand array format ( `[ 'item1' , 'item2', .....]` ).

I'll now cover each section and parameter in the following paragraphs.

### Main configuration values

`common.yaml` contains most of the configuration for Tiller. It contains top-level `exec`, `data_sources`, `template_sources` and `default_environment` parameters, along with sections for each environment. 

It can also take optional blocks of configuration for some plugins (for example, the [Consul Plugins](docs/plugins/consul.md)). Settings defined here can also be overridden on a per-environment basis (see [below](#overriding-common-settings))

* `exec`: This is simply what will be executed after the configuration files have been generated. If you omit this (or use the `-n` / `--no-exec` arguments) then no child process will be executed. As of 0.5.1, you can also specify the command and arguments as an array, e.g.

```yaml
	exec: [ "/usr/bin/supervisord" , "-n" ]
```

This means that a shell will not be spawned to run the command, and no shell expansion will take place. This is the preferred form, as it means that signals should propagate properly through to spawned processes. However, you can still use the old style string parameter, e.g.

```yaml
	exec: "/usr/bin/supervisord -n"
```

* `data_sources` : The data source plugins you'll be using to populate the configuration files. This should usually just be set to "file" to start with, although you can write your own plugins and pull them in (more on that later).
* `template_sources` Where the templates come from, again a list of plugins.
* `default_environment` : Sets the default environment file to load if none is specified (either using the -e flag, or via the `environment` environment variable). This defaults to 'development', but you may want to set this to 'production' to mimic the old, pre-0.4.0 behaviour.

So for a simple use-case where you're just generating everything from files and then spawning MongoDB, you'd have a common.yaml with this at the top:
```yaml
exec: [ "/usr/bin/mongod" , "--config" , "/etc/mongodb.conf" , "--rest" ]
data_sources: [ "file" ]
template_sources: [ "file" ]
```

## Template files

When using the `FileTemplateSource` ("file") plugin, these files under `/etc/tiller/templates` are simply the ERB templates for your configuration files, and are populated with values from the selected environment configuration blocks (see below). When the environment configuration is parsed (see below), key:value pairs are made available to the template. 

**IMPORTANT: **These files must be named with a suffix of `.erb`. Any files without an ending of `.erb` will be ignored.

Here's a practical example, again using MongoDB. Let's assume that you're setting up a "MongoDB" container for your platform to use, and you want to have it configured so it can run in 3 environments: 

* A local "development" environment (e.g. your own laptop), where you don't want to use it in a replica set.
* "staging" and "production" environments, both of which are setup to be in a replica set, named after the environment.

MongoDB needs to have the replica set name specified in the configuration file when it's launched. You'd therefore create a template `templates/mongodb.erb` template with some placeholder values:

```erb
... (rest of content snipped) ...
	
# in replica set configuration, specify the name of the replica set
<% if (replSet) %>
replSet = <%= replSet %>
<% end %> 
	
... (rest of content snipped) ...
```

Now it will only contain the `replSet = (whatever)` line when there is a variable "`replSet`" defined. How that gets defined is (usually) the job of the environment configuration blocks - these are covered next.

## Environment configuration

These headings in `common.yaml` (underneath the `environments:` key) are named after the environment variable `environment` that you pass in (usually by using `docker run -e environment=<whatever>`, which sets the environment variable). Alternatively, you can set the environment by using the `tiller -e` flag from the command line. 

When you're using the default `FileDataSource`, these environment blocks in `common.yaml` define the templates to be parsed, where the generated configuration file should be installed, ownership and permission information, and also a set of key:value pairs (the "template values") that are made available to the template via the usual `<%= key %>` ERB syntax.

Carrying on with the MongoDB example, here's how you might set the replica set name in your staging and production environments (add the following to `common.yaml`):

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

The development environment definition can be even simpler, as we don't actually define a replica set, so we can skip the whole `config` block :

```yaml
	development:

		mongodb.erb:
  			target: /etc/mongodb.conf
```

So now, when run through Tiller/Docker with `-e environment=staging`, the template will be installed to /etc/mongodb.conf with the following content :

	# in replica set configuration, specify the name of the replica set
	replSet = staging
	
Or, if the production environment is specified :

	# in replica set configuration, specify the name of the replica set
	replSet = production

And if the `development` environment is used (it's the default, so will also get used if no environment is specified), then the config file will get installed but with the line relating to replica set name left out.

Of course, this means you need an environment block for each replica set you plan on deploying. If you have many Mongo clusters you wish to deploy, you'll probably want to specify the replica set name dynamically, perhaps at the time you launch the container. You can do this in many different ways, for example by using the `environment` plugin to populate values from environment variables (`docker run -e repl_set_name=foo ...`) and so on. These plugins are covered in their [own documentation](#plugins).


### Overriding common settings
As of Tiller 0.5.0, you can also override defaults from common.yaml if you specify them in a `common` block in an environment section. This means you can specify a different `exec`, enable the API, or configure various plugins to use different settings on a per-environment basis, e.g.

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


