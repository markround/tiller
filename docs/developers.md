# General developer information

Tiller follows a fairly standard gem project layout and has a Rakefile, Gemfile and other assorted bits of scaffolding that hopefully makes development straightforward. 

## Setup

To get started, simply run `bundle install` in the top-level directory to install all the development dependencies. You should see something similar to the following:

	Using rake 10.4.2
	Using ffi 1.9.10
	Using childprocess 0.5.6
	...
	... Rest of output snipped
	...
	Using zk 1.9.5
	Using bundler 1.10.6
	Bundle complete! 7 Gemfile dependencies, 25 gems now installed.
	Use `bundle show [gemname]` to see where a bundled gem is installed.
	
You can now use the Rake tasks (through `bundle exec`)to build the gem :

	$ bundle exec rake build
	tiller 0.6.5 built to pkg/tiller-0.6.5.gem.
	
And then install the locally produced package :

	$ bundle exec rake install:local
	tiller 0.6.5 built to pkg/tiller-0.6.5.gem.
	tiller (0.6.5) installed.

I recommend Bundler version 1.10.6 or later; older versions may not have the 'install:local' job available.

## Tests

There are quite a few tests under the `features/` directory which use Cucumber and Aruba. Again, you can run these through a Rake task :

	$ bundle exec rake features
	Feature: Defaults module
	...
	... Rest of output snipped
	...
	22 scenarios (22 passed)
	70 steps (70 passed)
	0m6.500s
	
`bundle exec rake` with no arguments will by default build the gem, install it and then run the tests. You can see the status of builds across all branches of this gem at [https://travis-ci.org/](https://travis-ci.org/markround/tiller/branches) - these are run everytime I push to a origin branch on Github.

## Contributions

I welcome all bug reports and feature requests - please use the [Github issue tracker](https://github.com/markround/tiller/issues) to open a ticket. If you have any code, documentation or test coverage changes you'd like to send through, please create a fork from the [develop branch](https://github.com/markround/tiller/tree/develop), and submit a [Pull request](https://help.github.com/articles/using-pull-requests/), again based against the `develop` branch.

I'd also love to hear from anyone using Tiller, if you're doing anything cool with it or would like a link to your project just drop me a line (github@markround.com). Anyway, on with the technical details...


# Plugin architecture
Well, "architecture" is probably too grand a word, but as discussed in the main [README.md](README.md), you can get data into your template files from a multitude of sources, or even grab your template files from a source such as a database or from a HTTP server. Here's a quick overview:

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

The simplest possible example template source that returns one hard-coded template would be something like :

```ruby 
class ExampleTemplateSource < Tiller::TemplateSource
  def templates
    ["example.erb"]
  end
  def template(template_name)
    "I am an example template. Here is a value : <%= example %>"
  end
end
```


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

As with template sources, if you need to connect to a database or do any other post-initialisation work, create a `setup` method. You also have the `@config` instance variable available, which is a hash of the Tiller configuration (`common.yaml`).

The simplest possible example data source that returns one global value ("example") for all templates would look something like :

```ruby
class ExampleDataSource < Tiller::DataSource
  def global_values
    { 'example' => 'This is a global value' }
  end
end
```


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

## Logging
Both `Tiller::DataSource` and `Tiller::TemplateSource` have a log instance object available through `@log`. The verbosity is set to WARN by default but can be set to `INFO` when Tiller is called with the `-v` flag, and `DEBUG` when the `-d` flag is used. EG:

```ruby
class ExampleDataSource < Tiller::DataSource
  def setup
    @log.info('You will see this if you have run tiller with the -v flag')
    @log.debug('You will only see this if you have run tiller with the -d flag')
  end 
  ...
  ... Rest of file
  ...
end
```

## Configuration
If your plugin requires configuration, it's preferable that it reads it from a top-level configuration block in `common.yaml`, instead of requiring a separate configuration file.

## Documentation

If you want to get your plugin included with Tiller, documentation for your plugin should be included in a plugin_meta method at the top of the file. This should return a hash, e.g.

```ruby
def plugin_meta
  {
      id: "com.markround.tiller.data.example",
      name: "Example plugin",
      description: "A very cool plugin!",
      documentation: <<_END_DOCUMENTATION
# Example plugin

Here's the documentation for this plugin, in Markdown format.

_END_DOCUMENTATION
  }
end
```

This is useful for other users of your plugin, and will also be generated and added to the README.md when you run `./tools/plugin-docs.rb`. The keys in this hash are as follows :

 * id: A unique ID for your plugin. I choose to use Java-style reverse FQDNs, but you can use any identifier you want as long as it's unique.
 * title: The name of the plugin, as it will appear in the main README.md
 * description: A short description that will appear in the main README.md
 * documentation: Markdown documentation that will get generated and placed in docs/plugins/ as a separate file.


If you want to point to another plugin for documentation (e.g. in the case of the Consul plugins, the documentation covers both data and template sources), just include a `documentation_link:` key, with a pointer to where the documentation lives, e.g.

```ruby
def plugin_meta
  {
      id: 'com.markround.tiller.data.file',
      documentation_link: 'See main README.md'
  }
end
```

