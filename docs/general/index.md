# Usage
Tiller can be used to dynamically generate configuration files based on ERb templates before passing execution over to a daemon process or other command. It is usually used inside a Docker container as the `CMD` or `ENTRYPOINT` process.

In a basic use-case, when you are bundling your templates and configuration inside the container, all you need to do is tell Tiller which environment you want to use e.g. 

```
$ docker run -ti -e environment=staging my-application:latest
tiller v1.0.0 (https://github.com/markround/tiller) <github@markround.com>
Using common.yaml v2 format configuration file
Using configuration from /etc/tiller
Using plugins from /usr/local/lib/tiller
Using staging development
Template sources loaded [FileTemplateSource]
Data sources loaded [FileDataSource]
Available templates : ["application.erb"]
Building template application.erb
Not running as root, so not setting ownership/permissions on /etc/application.ini
Template generation completed
Executing ["/usr/sbin/my_application"]...
Child process forked with PID 87560
```

If no environment is specified, it will default to using "development".

# A word about configuration
Tiller uses YAML for configuration files. If you're unfamiliar with YAML, don't worry - it's very easy to pick up. A good introduction is here : ["Complete idiot's introduction to YAML"](https://github.com/Animosity/CraftIRC/wiki/Complete-idiot's-introduction-to-yaml)

Prior to Tiller v0.7, configuration was spread out over several files. If you had 3 environments (e.g. dev, stage and prod), you'd have a `common.yaml` for main configuration, one yaml file for each of your environments (`dev.yaml`,`stage.yaml` and so on), and possibly more depending on which plugins you'd enabled (`defaults.yaml` etc.)

However, 0.7 and later versions allow you to place most configuration inside a single `common.yaml` file, which can make things a lot clearer - you have a single place to view your configuration at once. I have therefore updated the documentation to cover this new style as the preferred approach. See [this blog post](http://www.markround.com/blog/2015/09/07/tiller-0-dot-7-0-and-simpler-configuration-files/) for an example.

Of course, you can always use the old "one file for each environment" approach if you prefer. Tiller is 100% backwards compatible with the old approach, and I have no intention of removing support for it as it's very useful in certain circumstances. The only thing to be aware of is that you can't mix the two configuration styles: If you configure some environments in `common.yaml`, Tiller will ignore any separate environment configuration files.
	    
# Arguments
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
* `--md5sum` : Only write templates if they do not already exist, or their content has changed (see [below](#checksums)). 
* `--md5sum-noexec` : If no templates were written/updated, do not execute any  process.



