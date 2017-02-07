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

## Documentation
The main documentation has been updated and a searchable, easy to read version is now hosted on [readthedocs.io](http://tiller.readthedocs.io/). You can also read the documentation by browsing the [docs](docs/) directory in this repository.

## Changes
See [changelog.md](docs/changelog.md)

## Support

For problems and improvements, feel free to open an [issue](https://github.com/markround/tiller/issues), or drop by the [Gitter channel](https://gitter.im/markround/tiller) to chat. These are the preferred options, as then others can see and benefit from any solutions. Alternatively, send me an email : github@markround.com and I'll do my best to help.

# Background
I had a number of Docker containers that I wanted to run with a slightly different configuration, depending on the environment I was launching them. For example, a web application might connect to a different database in a staging environment, a MongoDB replica set name might be different, or I might want to allocate a different amount of memory to a Java process. This meant my options basically looked like:

* Maintain multiple containers / Dockerfiles.
* Maintain the configuration in separate data volumes and use --volumes-from to pull the relevant container in.
* Bundle the configuration files into one container, and manually specify the `CMD` or `ENTRYPOINT` values to pick this up. 

None of those really appealed due to duplication, or the complexity of an approach that would necessitate really long `docker run` commands. 

So I knocked up a quick Ruby script (originally called "Runner.rb") that I could use across all my containers, which does the following :

* Generates configuration files from ERB templates (which can come from a number of sources)
* Uses values provided from a data source (i.e YAML files) for each environment
* Copies the generated templates to the correct location and specifies permissions
* Optionally executes a child process once it's finished (e.g. mongod, nginx, supervisord, etc.)
* Now provides a pluggable architecture, so you can define additional data or template sources. For example, you can create a DataSource that looks up values from an LDAP store, or a TemplateSource that pulls things from a database. 

This way I can keep all my configuration together in the container, and just tell Docker which environment to use when I start it. I can also use it to dynamically alter configuration at runtime ("parameterized containers") by passing in configuration from environment variables, external files, or a datastore such as Consul. 

## Why "Tiller" ?
Docker-related projects all seem to have shipyard-related names, and this was the first ship-building related term I could find that didn't have an existing gem or project named after it! And a tiller is the thing that steers a boat, so it sounded appropriate for something that generates configuration files.



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

## Separate configuration files per environment

Instead of placing all your environment configuration in `common.yaml`, you can split environment definitions out into separate files. This was the default behaviour of Tiller < 0.7.0, and will remain supported. To do this, create a `/etc/tiller/environments` directory, and then a yaml file named after your environment. 

For example, if you had a `/etc/tiller/common.yaml` that looked like the [example above](#complete-example), you would create a `/etc/tiller/environments/staging.yaml` file with the following content:

```yaml
mongodb.erb:
	target: /etc/mongodb.conf
	user: root
	group: root
	perms: 0644
	config:
		replSet: 'staging'
```
And so on, one for each environment. You would then remove the `environments:` block from `common.yaml`, and Tiller will switch to loading these individual files.

## Separate config files under config.d

If you want to further split out your configuration, you can create a `config.d` directory (usually at `/etc/tiller/config.d`) and place configuration fragments in separate YAML files under it. All these files will be loaded in order and merged together. Any configuration variable or block that would normally go in `common.yaml` can be split out into these separate files.

This is particularly useful for creating layered Docker images which inherit from a base. The base image could contain your default Tiller configuration, and you can then drop additional files under `config.d` to over-ride the defaults, or to specify new templates for that particular container.

See the [test fixture](https://github.com/markround/tiller/blob/master/features/config_d.feature) for some examples.

# Sub-templates

You can include other templates in your templates by using the built-in `Tiller::render` [helper module](#helper-modules). For example, if you have a template called `main.erb`, you can include another template called `sub.erb` by calling this module inside `main.erb`:

```erb
This is the main.erb template. 
This will include the sub.erb template below this line:
<%= Tiller::render('sub.erb') -%>
```

You can nest sub-templates as deeply as you wish, so you can have sub-templates including another sub-template and so on. However, it is important to note that all variables for sub-templates are evaluated only at the level of the top-level template. 

Therefore, trying to pass a variable to the sub-template by putting something like this in your `common.yaml` will not work:

```
sub.erb:
  config:
    sub_var: This is a var for the sub-template
```

You will not be able to access `sub_var` from your template - you will need to declare it in the `main.erb` block instead, where it will be available to all sub-templates.

# Checksums
You may wish to only write templates to disk if they do not already exist, or if their content has changed. You can pass the `--md5sum` flag on the command line, or set `md5sum: true` in your `common.yaml`. With this feature enabled, you'll see output like this in your logs:

```
[1/2] templates written, [1] skipped with no change
Template generation completed
```
If you pass the debug flag on the command-line (`-d` / `--debug`), you'll see further information like this amongst the output :

```
Building template test.erb
MD5 of test.erb is c377cfd6c73a5a9a334f949503b6e65d
MD5 of test.txt is c377cfd6c73a5a9a334f949503b6e65d
Content unchanged for test.erb, not writing anything
[0/1] templates written, [1] skipped with no change
```

If you also want to make sure a process is launched only if at least one file has been updated, you can pass the `--md5sum-noexec` command line option, or set `md5sum_noexec: true` in your `common.yaml`. 

# Dynamic configuration file
If you set the value `dynamic_config: true` in your `common.yaml`, you can use ERb syntax in your configuration values. For example, if you want to dynamically specify the location of a file from an environment variable, you could enable the `environment` plugin and do something like this:

`target: <%= env_target %>` 

And then pass the `target` environment variable at run-time. You can also call [helper modules](docs/developers.md#helper-modules) to populate values as well.


# API
There is a HTTP API provided for debugging purposes. This may be useful if you want a way of extracting and examining the configuration from a running container. Note that this is a *very* simple implementation, and should never be exposed to the internet or untrusted networks. Consider it as a tool to help debug configuration issues, and nothing more. Also see the "Gotchas" section if you experience any `Encoding::UndefinedConversionError` exceptions.

## Enabling
You can enable the API by passing the `--api` (and optional `--api-port`) command-line arguments. Alternatively, you can also set these in `common.yaml` :
	
```yaml
api_enable: true
api_port: 6275
```

## Usage
Once Tiller has forked a child process (specified by the `exec` parameter), you will see a message on stdout informing you the API is starting :

	Tiller API starting on port 6275
	
If you want to expose this port from inside a Docker container, you will need to add this port to your list of mappings (e.g. `docker run ... -p 6275:6275 ...`). You should now be able to connect to this via HTTP, e.g.

```
$ curl -D - http://docker-container-ip:6275/ping
HTTP/1.1 200 OK
Content-Type: application/json
Server: Tiller 0.3.1 / API v1

{ "ping": "Tiller API v1 OK" }

```

## Methods
The API responds to the following GET requests:

* **/ping** : Used to check the API is up and running.
* **/v2/config** : Return a hash of the Tiller configuration.
* **/v2/templates** : Return a list of generated templates.
* **/v2/template/{template_name}** : Return a hash of merged values and target values for the named template.


# Developer information
If you want to build your own plugins, or generally hack on Tiller, see [docs/developers.md](docs/developers.md)








