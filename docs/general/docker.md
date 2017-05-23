# Setup with Docker

This section will show how you can bundle Tiller inside a container so you can generate your configuration files at run-time, and then run your desired command.

Firstly install the Tiller gem and set your Dockerfile to use it. This assumes you're already pulling in a suitable version of Ruby, if not you may want to start by using `FROM ruby` :

```dockerfile
FROM ruby
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
	        ├── application.erb
	        ├── db.erb
	        ...
	        ... other configuration file templates go here
	        ...

It is suggested that you add all this under your Docker definition in a `data/tiller` base directory (e.g. data/tiller/common.yaml, data/tiller/templates and so on...) and then add it in your Dockerfile. This would therefore now look like:

```dockerfile
FROM ruby
RUN gem install tiller
...
... Rest of Dockerfile here
...
ADD data/tiller /etc/tiller
CMD ["/usr/local/bin/tiller" , "-v"]
```

Note that the configuration directory was added later on in the Dockerfile; this is because `ADD` commands cause the Docker build cache to become invalidated so it's a good idea to put them as far as possible towards the end of the Dockerfile.

Now, when you run the container, Tiller will run, generate your configuration files, and if you have set the `exec: ` parameter in your `common.yaml` will also start your specified program such as your application, database daemon, [supervisord](http://supervisord/org) etc.

# Setup with RVM
If you are using [RVM](http://rvm.io) to install a more recent Ruby in your container, you'll have to invoke BASH as a login shell in order to run RVM commands. For example, a Dockerfile based on CentOS 6 might look like:

```
FROM centos:centos6

# Install needed packages for RVM
RUN yum -y update && \
 yum -y groupinstall "Development Tools"

# Install RVM
RUN curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
RUN curl -L get.rvm.io | bash -s stable

# Install Tiller through RVM
RUN /bin/bash -l -c "rvm install 2.4.0 && \
        gem install bundler --no-ri --no-rdoc && \
        rvm use 2.4.0 --default && \
        gem update --system && \
        gem install tiller"

#
# ... Rest of Dockerfile goes here ...
#

# Run in a login shell so RVM can set up Ruby paths etc.
CMD ["/bin/bash" , "-l" , "-c" , "tiller"]

```

# Other resources
A simple tutorial which produces a 'parameterized' NginX container with Tiller is on my blog : [http://www.markround.com/blog/2014/09/18/tiller-and-docker-environment-variables/](http://www.markround.com/blog/2014/09/18/tiller-and-docker-environment-variables/). It also provides a downloadable archive of the files used in the example, so if you want to get up and running very quickly before diving into the rest of the documentation, then this may also be a good place to start.