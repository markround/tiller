# Setup with Docker

This section will show how you can bundle configuration and templates inside a container so you can switch between them at run-time, using just the "file" plugin.

All of the following assumes you're using Tiller with Docker. So, firstly install the Tiller gem and set your Dockerfile to use it (assuming you're pulling in a suitable version of Ruby already) :

```dockerfile
RUN gem install tiller
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
	    └── templates
	        ├── sensu_client.erb
	        ├── mongodb.erb
	        ...
	        ... other configuration file templates go here
	        ...

It is suggested that you add all this under your Docker definition in a `data/tiller` base directory (e.g. data/tiller/common.yaml, data/tiller/templates and so on...) and then add it in your Dockerfile. This would therefore now look like:
```dockerfile
RUN gem install tiller
...
... Rest of Dockerfile here
...
ADD data/tiller /etc/tiller
CMD ["/usr/local/bin/tiller" , "-v"]
```

Note that the configuration directory was added later on in the Dockerfile; this is because `ADD` commands cause the Docker build cache to become invalidated so it's a good idea to put them as far as possible towards the end of the Dockerfile.

# Other resources
A simple tutorial which produces a 'parameterized' NginX container with Tiller is on my blog : [http://www.markround.com/blog/2014/09/18/tiller-and-docker-environment-variables/](http://www.markround.com/blog/2014/09/18/tiller-and-docker-environment-variables/). It also provides a downloadable archive of the files used in the example, so if you want to get up and running very quickly before diving into the rest of the documentation, then this may also be a good place to start.