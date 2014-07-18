# Background
I had a number of Docker containers that I wanted to run with a slightly different configuration, depending on the environment I was launching them. For example, a web application might connect to a different database in a staging environment, or a MongoDB replica set name might be different. This meant my options basically looked like:

* Maintain multiple containers / Dockerfiles.
* Maintain the configuration in separate data volumes and use --volumes-from to pull the relevant container in.
* Bundle the configuration files into one container, and manually specify the `CMD` or `ENTRYPOINT` values to pick this up. 

None of those really appealed due to duplication, or the complexity of an approach that would necessitate really long `docker run` commands. 

So I knocked up a quick Ruby script (originally called "Runner.rb") that I could use across all my containers, which does the following :

* Generates configuration files from ERB templates (which can come from a number of sources)
* Uses values provided from a data source (i.e YAML files) for each environment
* Copies the generated templates to the correct location and specifies permissions
* Executes a replacement process once it's finished (e.g. mongod, nginx, supervisord, etc.)
* Now provides a pluggable architecture, so you can define additional data or template sources. For example, you can create a DataSource that looks up values from an LDAP store, or a TemplateSource that pulls things from a database. 

This way I can keep all my configuration together in the container, and just tell Docker which environment to use when I start it. 

## Why "Tiller" ?
Docker-related projects all seem to have shipyard-related names, and this was the first ship-building related term I could find that didn't have an existing gem or project named after it! And a tiller is the thing that steers a boat, so it sounded appropriate for something that generates configuration files.

# Usage
Tiller can be used to dynamically generate configuration files before passing execution over to a daemon process. 

It looks at an environment variable called "environment", and creates a set of configuration files based on templates, and then runs a specified daemon process via `exec`. Usually, when running a container that users Tiller, all you need to do is pass the environment to it, e.g. 

	# docker run -t -i -e environment=staging markround/demo_container:latest
	tiller v0.0.1 (https://github.com/markround/tiller) <github@markround.com>
	Using configuration from /etc/tiller
	Using plugins from /usr/local/lib/tiller
	Using environment production
	Template sources loaded [FileTemplateSource]
	Data sources loaded [FileDataSource, NetworkDataSource]
	Templates to build ["mongodb.erb", "sensu_client.erb"]
	Building template mongodb.erb
	Setting ownership/permissions on /etc/mongodb.conf
	Building template sensu_client.erb
	Setting ownership/permissions on /etc/sensu/conf.d/client.json
	Template generation completed, about to exec replacement process.
	Calling /usr/bin/supervisord...

If no environment is specified, it will default to using "production".

# Setup

Firstly, install the tiller gem and set your Dockerfile to use it (assuming you're pulling in a suitable version of Ruby already) :

	CMD gem install tiller
	ADD data/tiller/common.yaml /etc/tiller/common.yaml
	...
	... Rest of Dockerfile here
	...
	CMD /usr/bin/tiller

Now, set up your configuration. By default, Tiller looks for configuration under `/etc/tiller`, but this can be set to somewhere else by setting the environment variable `tiller_base`. This is particularly useful for testing purposes, e.g.

	$ tiller_base=$PWD/tiller tiller

Tiller expects a directory structure like this (using /etc/tiller as it's base, and the file data and template sources) :

	etc
	└── runner
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

It is suggested that you add all this under your Docker definition in a `data/tiller` base directory (e.g. data/tiller/common.yaml, data/tiller/environments and so on...) and then add it in your Dockerfile :

	ADD data/tiller /etc/tiller

## Common configuration
`common.yaml` contains the `exec`, `data_sources` and `template_sources` parameters. 

* `exec`: This is simply what will be executed after the configuration files have been generated. 
* `data_sources` : The data sources you'll be using to populate the configuration files. This should usually just be set to "file" to start with, although you can write your own plugins and pull them in (more on that later).
* `template_sources` Where the templates come from, again a list of plugins. 

So for a simple use-case where you're just generating everything from files and then spawning supervisors, you'd have a common.yaml looking like this:

	exec: /usr/bin/supervisord
	data_sources:
		- file
	template_sources:
		-file

## Environment configuration

These files are named after the environment variable `environment` that you pass in (using `docker run -e`, or from the command line) They define the templates to be parsed, where the generated configuration file should be installed, ownership and permission information, and a set of key:value pairs that are made available to the template. 

Example: In your <environment>.yaml file, let's assume you want to define some parameters for an application. For example, assume you wanted to use a different MongoDB replica set name in your staging environment. Here's how you might set the replica set name in your `staging.yaml` environment file :

	mongodb.erb:
	  target: /etc/mongodb.conf
	  user: root
	  group: root
	  perms: 0644
	  config:
	    replSet: 'stage'

And then your `production.yaml` (which everything will use if you don't specify an environment) might contain the defaults :

	mongodb.erb:
	  target: /etc/mongodb.conf
	  config:
	    replSet: 'production'

Note that if you omit the user/group/perms parameters, the defaults are root:root, 0644. Also, if you don't run the script as root, it will skip setting these.

## Template files

These are simply the ERB templates for your configuration files, and are populated with values from the selected environment file. When the environment configuration is parsed (see above), key:value pairs are made available to the template. Note, this is different to the old behaviour of my "Runner.rb" script, as this required you to use the `config` hash. Using MongoDB as an example again, you'd have a `/etc/runner/templates/mongodb.erb` with the following content:

	... (rest of content snipped) ...
	
	# in replica set configuration, specify the name of the replica set
	<% if (replSet) %>
	replSet = <%= replSet %>
	<% end %> 
	
	... (rest of content snipped) ...

	
Which, when run through Tiller/Docker with `-e environment=staging`, produces the following :

	# in replica set configuration, specify the name of the replica set
	replSet = stage
	
Or, if no environment is specified :

	# in replica set configuration, specify the name of the replica set
	replSet = production

# Plugin architecture
Well, "architecture" is probably too grand a word, but you can get data into your template files from a multitude of sources, or even grab your template files from a source such as a database or from a HTTP server. I've included some examples under the `examples/` directory, including dummy sources that return dummy data and templates, and a NetworkDataSource that provides the host's FQDN and a hash of IP address details, which templates can use. Have a look at those for a fuller example, but here's a quick overview:

##Template sources
These are modules that provide a list of templates, and return the template contents. The code for the `FileDataSource` module is really simple. It pretty much just does this to return a list of templates :

    Dir.glob(File.join(@template_dir , '**' , '*.erb')).each do |t|
      t.sub!(@template_dir , '')
    end
  
And then to return an individual template, it just does :
 
    open(File.join(@template_dir , template_name)).read
 
You can create your own template provider by extending the `Tiller::TemplateSource` class and providing two methods :

* `templates` : Return an array of templates available
* `template(template_name)` : Return a string containing an ERB template for the given `template_name`

When the class is created, it gets passed a hash containing various variables you can use to return different templates based on environment etc. Or you can read in `common.yaml` yourself and pull additional variables out of it.

##Data sources
These provide values that templates can use. There are 3 kinds of values:
 
* global values which all templates can use (`environment` is provided like this), and could be things like a host's IP address, FQDN, or any other value.
* local values which are values provided for each template
* target values which provide information about where a template should be installed to, what permissions it should have, and so on.

 The `FileDataSource` module only provide local and target values, and Tiller itself provides the `environment` global value. However, you can create your own datasources by inheriting `Tiller::DataSource` and providing 3 methods :
 
* `values(template_name)` : Return a hash of keys/values for the given template name
* `target_values(template_name)` : Return a hash of values for the given template name, which must include:
	* `target` : The full path that the populated template should be installed to (directories will be created if they do not exist)
	* `user` : The user that the file should be owned by (e.g. root)
	* `group` : The group that the file should be owned by (e.g. bin)
	* `perms`: The octal permissions the file should have (e.g. 0644)
* `global_values` : Return a hash of global values. This is implemented as a class variable `@global_values` made accessible through `attr_accessor`, but you can easily override this in your own class.

## Naming
Assuming you had created a pair of template and data source plugins called `ExampleTemplateSource` and `ExampleDataSource`, you'd drop them under `/usr/local/lib/tiller/template/example.rb` and `/usr/local/lib/tiller/data/example.rb` respectively, and then add them to `common.yaml` :

	data_sources:
		- file
		- example
	template_sources:
		-file
		-example

## Gotchas
Tiller will merge values from all sources. It will warn you, but it won't stop you from doing this, which may have undefined results. Particularly if you include two data sources that each provide target values - you may find that your templates end up getting installed in locations you didn't expect, or containing spurious values!

# Future improvements

* Tests
* Clean up my gnarly code
* Add more plugins, including an etcd backend.
* Anything else ?

# License

MIT. See the included LICENSE file.


