# What is it?
Tiller is a tool that generates configuration files. It takes a set of templates, fills them in with values from a variety of sources (such as environment variables, YAML files, JSON from a webservice...), installs them in a specified location and then optionally spawns a child process.

You might find this particularly useful if you're using Docker, as you can ship a set of configuration files for different environments inside one container, and easily build "parameterized containers" which users can easily configure at runtime. 

However, its use is not just limited to Docker; you may also find it useful as a sort of "proxy" that can provide values to application configuration files from a data source that the application does not natively support. 

It's available as a [Ruby Gem](http://https://rubygems.org/gems/tiller), so installation should be a simple `gem install tiller`.

[![Gem Version](https://badge.fury.io/rb/tiller.svg)](http://badge.fury.io/rb/tiller)
[![Build Status](https://travis-ci.org/markround/tiller.svg?branch=develop)](https://travis-ci.org/markround/tiller)
![](http://ruby-gem-downloads-badge.herokuapp.com/tiller?type=total)

## More information
You may find a lot of the flexibility that Tiller offers overwhelming at first. I have written a few blog tutorials that provide a good overview of what Tiller can do, with practical examples; I strongly recommend that if you're new to all this, you read the following articles through for an introduction :  

* Introducing Tiller : [http://www.markround.com/blog/2014/07/18/tiller-and-docker-container-configuration/](http://www.markround.com/blog/2014/07/18/tiller-and-docker-container-configuration/). 

* Walkthrough tutorial : [http://www.markround.com/blog/2014/09/18/tiller-and-docker-environment-variables/](http://www.markround.com/blog/2014/09/18/tiller-and-docker-environment-variables/)

* Using the Environment JSON plugin : [http://www.markround.com/blog/2014/10/17/building-dynamic-docker-images-with-json-and-tiller-0-dot-1-4/](http://www.markround.com/blog/2014/10/17/building-dynamic-docker-images-with-json-and-tiller-0-dot-1-4/)

* Querying the Tiller API : [http://www.markround.com/blog/2014/10/20/querying-tiller-configuration-from-a-running-docker-container/](http://www.markround.com/blog/2014/10/20/querying-tiller-configuration-from-a-running-docker-container/)

* Using the Defaults data source : [http://www.markround.com/blog/2014/12/05/tiller-0.3.0-and-new-defaults-datasource](http://www.markround.com/blog/2014/12/05/tiller-0.3.0-and-new-defaults-datasource)

See the [Tiller category](http://www.markround.com/blog/categories/tiller/) on my blog for a full list of articles and other information.

## Changes
See [CHANGELOG.md](CHANGELOG.md)

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

This way I can keep all my configuration together in the container, and just tell Docker which environment to use when I start it. I can also use it to dynamically alter configuration at runtime ("parameterized containers").

## Why "Tiller" ?
Docker-related projects all seem to have shipyard-related names, and this was the first ship-building related term I could find that didn't have an existing gem or project named after it! And a tiller is the thing that steers a boat, so it sounded appropriate for something that generates configuration files.


# Usage
Tiller can be used to dynamically generate configuration files before passing execution over to a daemon process. 

It looks at an environment variable called "environment" (or the argument to the `-e` flag), and creates a set of configuration files based on templates, and then optionally runs a specified daemon process via `exec`. Usually, when running a container that uses Tiller, all you need to do is pass the environment to it, e.g. 

	# docker run -t -i -e environment=staging markround/demo_container:latest
	tiller v0.3.1 (https://github.com/markround/tiller) <github@markround.com>
	Using configuration from /etc/tiller
	Using plugins from /usr/local/lib/tiller
	Using environment staging
	Template sources loaded [FileTemplateSource]
	Data sources loaded [FileDataSource, NetworkDataSource]
	Templates to build ["mongodb.erb", "sensu_client.erb"]
	Building template mongodb.erb
	Setting ownership/permissions on /etc/mongodb.conf
	Building template sensu_client.erb
	Setting ownership/permissions on /etc/sensu/conf.d/client.json
	Template generation completed
	Executing /usr/bin/supervisord
	Child process forked.

If no environment is specified, it will default to using "development". Prior to version 0.4.0, this used to be "production", but as was quite rightly pointed out, this is a bit scary. You can always change the default anyway - see below. 

## Arguments
Tiller understands the following *optional* command-line arguments (mostly used for debugging purposes) :

* `-n` / `--no-exec` : Do not execute a child process (e.g. you only want to generate the templates)
* `-v` / `--verbose` : Display verbose output, useful for debugging and for seeing what templates are being parsed
* `-d` / `--debug` : Enable additional debug output
* `-b` / `--base-dir` : Specify the tiller_base directory for configuration files
* `-l` / `--lib-dir` : Specify the tiller_lib directory for user-provided plugins
* `-e` / `--environment` : Specify the tiller environment. This is usually set by the 'environment' environment variable, but this may be useful for debugging/switching between environments on the command line.
* `-a` / `--api` : Enable the HTTP API (See below)
* `-p` / `--api-port` : Set the port the API listens on (Default: 6275)
* `-x` / `--exec` : Specify an alternate command to execute, overriding the exec: parameter from your config files
* `-h` / `--help` : Show a short help screen

# Setup
All of the following assumes you're using Tiller with Docker. So, firstly install the Tiller gem and set your Dockerfile to use it (assuming you're pulling in a suitable version of Ruby already) :

```dockerfile
CMD gem install tiller
...
... Rest of Dockerfile here
...
CMD ["/usr/local/bin/tiller" , "-v"]
```

Now, set up your configuration. By default, Tiller looks for configuration under `/etc/tiller`, but this can be set to somewhere else by setting the environment variable `tiller_base` or by using the `-b` flag. This is particularly useful for testing purposes, e.g.

	$ tiller_base=/tmp/tiller tiller -v
	
or

	$ tiller -v -b /tmp/tiller

Tiller expects a directory structure like this (using /etc/tiller as its base, and the file data and template sources) :

	etc
	└── tiller
	    ├── common.yaml
	    │
	    ├── environments
	    │   ├── production.yaml
	    │   ├── staging.yaml
	    │   ...
	    │   ... other environments defined here
	    │   ...
	    │
	    └── templates
	        ├── sensu_client.erb
	        ├── mongodb.erb
	        ...
	        ... other configuration file templates go here
	        ...

It is suggested that you add all this under your Docker definition in a `data/tiller` base directory (e.g. data/tiller/common.yaml, data/tiller/environments and so on...) and then add it in your Dockerfile. This would therefore now look like:
```dockerfile
CMD gem install tiller
...
... Rest of Dockerfile here
...
ADD data/tiller /etc/tiller
CMD ["/usr/local/bin/tiller" , "-v"]
```

Note that the configuration directory was added later on in the Dockerfile; this is because `ADD` commands cause the Docker build cache to become invalidated so it's a good idea to put them as far as possible towards the end of the Dockerfile.

## Common configuration
`common.yaml` contains the `exec`, `data_sources`, `template_sources` and `default_environment` parameters. It can also take optional blocks of configuration for some plugins (for example, the [HTTP Plugins](README-HTTP.md)). Settings defined here can also be overridden on a per-environment basis (see [below](#overriding-common-settings))

* `exec`: This is simply what will be executed after the configuration files have been generated. If you omit this (or use the `-n` / `--no-exec` arguments) then no child process will be executed. As of 0.5.1, you can also specify the command and arguments as an array, e.g.

```yaml
	exec: [ "/usr/bin/supervisord" , "-n" ]
```

This means that a shell will not be spawned to run the command, and no shell expansion will take place. This is the preferred form, as it means that signals should propagate properly through to spawned processes. However, you can still use the old style string parameter, e.g.

```yaml
	exec: "/usr/bin/supervisord -n"
```

* `data_sources` : The data sources you'll be using to populate the configuration files. This should usually just be set to "file" and "environment" to start with, although you can write your own plugins and pull them in (more on that later).
* `template_sources` Where the templates come from, again a list of plugins.
* `default_environment` : Sets the default environment file to load if none is specified (either using the -e flag, or via the `environment` environment variable). This defaults to 'development', but you may want to set this to 'production' to mimic the old, pre-0.4.0 behaviour.

So for a simple use-case where you're just generating everything from files or environment variables and then spawning MongoDB, you'd have a common.yaml looking like this:
```yaml
	exec: [ "/usr/bin/mongod" , "--config" , "/etc/mongodb.conf" , "--rest" ]
	data_sources:
		- file
		- environment
	template_sources:
		- file
```

### Ordering
Since Tiller 0.3.0, the order you specify these plugins in is important. They'll be used in the order you specify, so you can order them to your particular use case. For example, you may want to retrieve values from the `defaults` data source, then overwrite that with some values from the `file` data source, and finally allow users to set their own values from the `environment_json` source (see below for more on each of these). In which case, you'd specify :
```yaml
data_sources:
  - defaults
  - file
  - environment_json
```

Note also that template-specific values take priority over global values (see the Gotchas section for an example).

## Template files

These files under `/etc/tiller/templates` are simply the ERB templates for your configuration files, and are populated with values from the selected environment file. When the environment configuration is parsed (see below), key:value pairs are made available to the template. 

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

Now it will only contain the `replSet = (whatever)` line when there is a variable "`replSet`" defined. How that gets defined is (usually) the job of the environment files - these are covered next.

## Environment configuration

These files live under `/etc/tiller/environments` and are named after the environment variable `environment` that you pass in (by using `docker run -e`, or from the command line). Alternatively, you can set the environment by using the `-e` flag from the command line.

When you're using the default `FileDataSource`, these environment files define the templates to be parsed, where the generated configuration file should be installed, ownership and permission information, and also a set of key:value pairs that are made available to the template via the usual `<%= key %>` ERB syntax.

Carrying on with the MongoDB example, here's how you might set the replica set name in your `staging.yaml` environment file :
```yaml
mongodb.erb:
  target: /etc/mongodb.conf
  user: root
  group: root
  perms: 0644
  config:
    replSet: 'staging'
```
And then your `production.yaml` might look like the following :
```yaml
mongodb.erb:
  target: /etc/mongodb.conf
  config:
    replSet: 'production'
```
Note that if you omit the user/group/perms parameters, the defaults are whatever Docker runs as (usually root). Also, if you don't run the script as root, it will skip setting these.

The `development.yaml` can be even simpler, as we don't actually define a replica set, so we can skip the whole `config` block :

```yaml
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

Of course, this means you need an environment file for each replica set you plan on deploying. If you have many Mongo clusters you wish to deploy, you'll probably want to specify the replica set name dynamically, perhaps at the time you launch the container. You can do this in many different ways, for example by using the `environment` plugin to populate values from environment variables (`docker run -e repl_set_name=foo ...`) and so on. These plugins are covered in the next section.

### Overriding common settings
As of Tiller 0.5.0, you can also override defaults from common.yaml if you specify them in a `common` block in an environment file. This means you can specify a different `exec`, enable the API, or configure various plugins to use different settings on a per-environment basis, e.g.

```yaml
common:
  api_enable: true
  api_port: 1234
  
  # configuration for HTTP plugin (https://github.com/markround/tiller/blob/master/README-HTTP.md)
  http:
    uri: 'http://tiller.dev.example.com'
    ...
    ...
    ...
```


## Plugins

In addition to specifying values in the environment files, there are other plugins that can also provide values to be used in your templates, and you can easily write your own. The plugins that ship with Tiller are :

### File plugins
These provide data from YAML environment files, and templates from ERB files (see above).

### HTTP plugins
These allow you to retrieve your templates and values from a HTTP server. Full documentation for this plugin is available in [README-HTTP.md](README-HTTP.md)

### ZooKeeper plugins
These allow you to store your templates and values in a [ZooKeeper](http://zookeeper.apache.org) cluster. Full documentation for this plugin is available in [README-zookeeper.md](README-zookeeper.md)

### Defaults plugin
If you add `  - defaults` to your list of data sources in `common.yaml`, you'll be able to make use of default values for your templates, which can save a lot of repeated definitions if you have a lot of common values shared between environments. These defaults are sourced from `/etc/tiller/defaults.yaml`, and any individual `.yaml` files under `/etc/tiller/defaults.d/`. Top-level configuration keys are `global` for values available to all templates, and a template name for values only available to that specific template. For example:
```yaml
global:
  domain_name: 'example.com'
	  
application.properties.erb:
  java_version: 'jdk8'
```

### Environment plugin
If you activated the `EnvironmentDataSource` (as shown by adding `  - environment` to the list of data sources in the example `common.yaml` above), you'll also be able to access environment variables within your templates. These are all converted to lower-case, and prefixed with `env_`. So for example, if you had the environment variable `LOGNAME` set, you could reference this in your template with `<%= env_logname %>`

### Environment JSON
If you add `  - environment_json` to your list of data sources in `common.yaml`, you'll be able to make complex JSON data structures available to your templates. Just pass your JSON in the environment variable `tiller_json`. See [http://www.markround.com/blog/2014/10/17/building-dynamic-docker-images-with-json-and-tiller-0-dot-1-4/](http://www.markround.com/blog/2014/10/17/building-dynamic-docker-images-with-json-and-tiller-0-dot-1-4/) for some practical examples.

### Random plugin
If you add `  - random` to your list of data sources in `common.yaml`, you'll be able to use randomly-generated values and strings in your templates, e.g. `<%= random_uuid %>`. This may be useful for generating random UUIDs, server IDs and so on. An example hash with demonstration values is as follows : 

	{"random_base64"=>"nubFDEz2MWlIiJKUOQ+Ttw==",
	 "random_hex"=>"550de401ef69d92b250ce379e5a5957c",
	 "random_bytes"=>"3\xC8fS\x11`\\W\x00IF\x95\x9F8.\xA7",
	 "random_number_10"=>8,
	 "random_number_100"=>71,
	 "random_number_1000"=>154,
	 "random_urlsafe_base64"=>"MU9UP8lEOVA3Nsb0OURkrw",
	 "random_uuid"=>"147acac8-7229-44af-80c1-246cf08910f5"}


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
* **/v1/config** : Return a hash of the Tiller configuration.
* **/v1/globals** : Return a hash of global values from all data sources.
* **/v1/templates** : Return a list of generated templates.
* **/v1/template/{template_name}** : Return a hash of merged values and target values for the named template.


# Plugin architecture
Well, "architecture" is probably too grand a word, but as discussed above, you can get data into your template files from a multitude of sources, or even grab your template files from a source such as a database or from a HTTP server. I've included some examples under the `examples/` directory, including dummy sources that return dummy data and templates, and a NetworkDataSource that provides the host's FQDN and a hash of IP address details, which templates can use. Have a look at those for a fuller example, but here's a quick overview:

##Template sources
These are modules that provide a list of templates, and return the template contents. The code for the `FileTemplateSource` module is really simple. It pretty much just does this to return a list of templates :
```ruby
    Dir.glob(File.join(@template_dir , '**' , '*.erb')).each do |t|
      t.sub!(@template_dir , '')
    end
```  
And then to return an individual template, it just does :
```ruby 
    open(File.join(@template_dir , template_name)).read
``` 
You can create your own template provider by extending the `Tiller::TemplateSource` class and providing two methods :

* `templates` : Return an array of templates available
* `template(template_name)` : Return a string containing an ERB template for the given `template_name`

If you create a `setup` method, it will get called straight after initialization. This can be useful for connecting to a database, parsing configuration files and so on.

When the class is created, it gets passed a hash containing various variables you can use to return different templates based on environment etc. Or you can read any values from `common.yaml` yourself, as it's accessible from the instance variable `@config`.

##Data sources
These provide values that templates can use. There are 3 kinds of values:
 
* global values which all templates can use (`environment` is provided like this), and could be things like a host's IP address, FQDN, or any other value.
* local values which are values provided for each template
* target values which provide information about where a template should be installed to, what permissions it should have, and so on.

You can create your own datasources by inheriting `Tiller::DataSource` and providing any of the following 3 methods :
 
* `values(template_name)` : Return a hash of keys/values for the given template name
* `target_values(template_name)` : Return a hash of values for the given template name, which must include:
	* `target` : The full path that the populated template should be installed to (directories will be created if they do not exist)
	* `user` : The user that the file should be owned by (e.g. root)
	* `group` : The group that the file should be owned by (e.g. bin)
	* `perms`: The octal permissions the file should have (e.g. 0644)
* `global_values` : Return a hash of global values. 

As with template sources, if you need to connect to a database or do any other post-initialisation work, create a `setup` method.

## Naming
Assuming you had created a pair of template and data source plugins called `ExampleTemplateSource` and `ExampleDataSource`, you'd drop them under `/usr/local/lib/tiller/template/example.rb` and `/usr/local/lib/tiller/data/example.rb` respectively, and then add them to `common.yaml` :

```yaml
data_sources:
  - file
  - example
  - random
template_sources:
  - file
  - example
```

If you don't want to use the default directory of `/usr/local/lib/tiller`, you can specify an alternate location by setting the `tiller_lib` environment variable, or by using the `-l`/`--libdir` flag on the command line.

# Gotchas
## Merging values
Tiller will merge values from all sources. It will warn you, but it won't stop you from doing this, which may have undefined results. Particularly if you include two data sources that each provide target values - you may find that your templates end up getting installed in locations you didn't expect, or containing spurious values!

## Empty config
If you are using the file datasource with Tiller < 0.2.5, you must provide a config hash, even if it's empty (e.g. you are using other data sources to provide all the values for your templates). For example:

```yaml
my_template.erb:
  target: /tmp/template.txt
  config: {}
```

Otherwise, you'll probably see an error message along the lines of :

```
/var/lib/gems/1.9.1/gems/tiller-0.2.4/bin/tiller:149:in `merge!': can't convert nil into Hash (TypeError)
```

After 0.2.5, you can leave the config hash out altogether if you are providing all your values from another data source (or don't want to provide any values at all).

## ERb newlines
By default, ERb will insert a newline character after a closing `%>` tag. You may not want this, particularly with loop constructs. As of version 0.1.5, you can suppress the newline using a closing tag prefixed with a `-` character, e.g. 

```erb
<% things.each do |thing| -%>
	<%= thing %>
<% end -%>
```
You may also need tell your editor to use Unix-style line endings. For example, in VIM :

	:set fileformat=unix

## API Encoding::UndefinedConversionError exceptions
This seems to crop up mostly on Ruby 1.9 installations, and happens when converting ASCII-8BIT strings to UTF-8. A workaround is to install the 'Oj' gem, and Tiller will use this if it's found. I didn't make it a hard dependency of Tiller as Oj is a C-library native extension, so you'll need a bunch of extra packages which you may consider overkill on a Docker container. E.g. on Ubuntu, you'll need `ruby-dev`, `make`, a compiler and so on. But if you have all the dependencies, a simple `gem install oj` in your Dockerfile or environment should be all you need.

## Signal handling
Not a "gotcha" as such, but worth noting. Since version 0.4.0, Tiller catches the `INT`,`TERM` and `HUP` signals and passes them on to the child process spawned through `exec`. This helps avoid the ["PID 1"](http://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/) problem by making sure that if Tiller is killed then the child process should also exit.

## Global and local value precedence 
A "global" value will be over-written by a local value (e.g. a value specified for a template in a `config:` block). This may cause you unexpected behaviour when you attempt to use a value from a data source such as `environment_json` or `environment` which exposes its values as global values.

For example, if you have the following in an environment file :

```yaml
my_template.erb:
  target: /tmp/template.txt
  config:
    test: 'This is a default value'
```

And then use the environment_json plugin to try and over-ride this value, like so :

`$ tiller_json='{ "test" : "From JSON!" }' tiller -n -v ......`

You'll find that you won't see the "From JSON!" string appear in your template, no matter what order you load the plugins. This is because the `test` value in your environment configuration is a local, per-template value and thus will always take priority over a global value. If you want to provide a default, but allow it to be over-ridden, the trick is to use the `defaults` plugin to provide the default values (so all global data sources are merged in the correct order). See [This blog post](http://www.markround.com/blog/2014/10/17/building-dynamic-docker-images-with-json-and-tiller-0-dot-1-4/) for an example.



# Other examples, articles etc.

* [http://www.markround.com/blog/2014/07/18/tiller-and-docker-container-configuration/](http://www.markround.com/blog/2014/07/18/tiller-and-docker-container-configuration/) - Introductory blog post that provides a quick overview and shows an example DataSource at the end.
* [http://www.markround.com/blog/2014/09/18/tiller-and-docker-environment-variables/](http://www.markround.com/blog/2014/09/18/tiller-and-docker-environment-variables/) - Walkthrough tutorial showing how to use Tiller's environment plugin. Includes a Dockerfile and downloadable example.
* [http://www.markround.com/blog/2014/10/17/building-dynamic-docker-images-with-json-and-tiller-0-dot-1-4/](http://www.markround.com/blog/2014/10/17/building-dynamic-docker-images-with-json-and-tiller-0-dot-1-4/) - Demonstration of using the JSON datasource, and shows how you can use it to over-ride default values or provide images that can be configured dynamically by end-users.
* [http://www.markround.com/blog/2014/10/20/querying-tiller-configuration-from-a-running-docker-container/](http://www.markround.com/blog/2014/10/20/querying-tiller-configuration-from-a-running-docker-container/) - Demonstration of querying the Tiller API to extract the information on generated templates.
* [http://www.markround.com/blog/2014/12/05/tiller-0.3.0-and-new-defaults-datasource](http://www.markround.com/blog/2014/12/05/tiller-0.3.0-and-new-defaults-datasource) - Shows how you can use the Defaults data source, and covers the changes in plugin loading behaviour.


# Future improvements

* Please open an [issue](https://github.com/markround/tiller/issues) for any improvements you'd like to see!

# License

MIT. See the included LICENSE file.


