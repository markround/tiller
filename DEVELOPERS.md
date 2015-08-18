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
Well, "architecture" is probably too grand a word, but as discussed in the main [README.md](README.md), you can get data into your template files from a multitude of sources, or even grab your template files from a source such as a database or from a HTTP server. I've included some examples under the `examples/` directory, including dummy sources that return dummy data and templates, and a NetworkDataSource that provides the host's FQDN and a hash of IP address details, which templates can use. Have a look at those for a fuller example, but here's a quick overview:

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

As with template sources, if you need to connect to a database or do any other post-initialisation work, create a `setup` method. 

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
