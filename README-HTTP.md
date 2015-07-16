# HTTP plugins

As of version 0.6.1, Tiller includes plugins to retrieve templates and values from a HTTP server. These plugins rely on the `httpclient` gem to be present, so before proceeding ensure you have run `gem install httpclient` in your environment. This is not listed as a hard dependency of Tiller, as this would force the gem to be installed even on systems that would never use these plugins.

# Response format
The plugins expect data to be returned in JSON format, apart from the template content which is expected to be in plain text. Additional parsers will be added in the future.

# Enabling the plugin
Add the `http` plugins in your `common.yaml`, e.g.

```yaml 
data_sources:
  - file
  - http
template_sources:
  - http
  - file
```

Note that the ordering is significant. In the above example, values from the HTTP data source will take precedence over YAML files, but templates loaded from files will take precedence over templates stored in HTTP. You should tweak this as appropriate for your environment.

You also do not need to enable both plugins; for example you may just want to retrieve values for your templates from a web server, but continue to use files to store your actual template content.

# Configuring
Configuration for this plugin is placed inside a "http" block. This can either be included in the main `common.yaml` file, or in a per-environment file inside the `common:` block. See the main [README.md](https://github.com/markround/tiller/blob/master/README.md#common-configuration) for more information on this. 

A sample configuration (showing the defaults for most parameters) is as follows :

```yaml
http:
  uri: 'http://tiller.example.com'
  timeout: 5
  templates: '/tiller/environments/%e/templates'
  template_content: '/tiller/templates/%t/content'

  values:
    global: '/tiller/globals'
    template: '/tiller/templates/%t/values/%e'
    target: '/tiller/templates/%t/target_values/%e'
```

At a bare minimum, you need to specify a URI for the plugins to connect to. This takes the form of a standard HTTP/HTTPS connection string (including the scheme). For example, `http://tiller.example.com`. This will be prepended to any of the other paths, so in the above example, Tiller will look for global values at `http://tiller.example.com/tiller/globals`. 

The default timeout is 5 seconds; if a connection to a HTTP server takes longer than this, the connection will abort and Tiller will stop with an exception.

Note that as you can specify `common:` blocks in each environment file, you can specify a different URI per environment. 

If you omit the other parameters (`timeout`,`templates` and so on), they will default to the values shown above. 

## Authentication
If the HTTP server you are connecting to requires basic Authentication, you can include `username` and `password` keys in your configuration:

```yaml
http:
  username: 'user01'
  password: 'p4ssw0rd!'
```

## Proxy server
If your environment requires the use of a HTTP proxy server to reach your Tiller configuration server, you can add a `proxy` key to your configuration, and optionally `proxy_username` and `proxy_password` keys if it requires basic authentication :

```yaml
http:
  proxy: 'http://proxy.example.com:3128'
  proxy_username: 'proxy_user'
  proxy_password: 'p4ssw0rd!'
```


# Paths
You can use any URI hierarchy, but the default is expected to look like the following (again, using MongoDB configuration as an example):

	/tiller
	 ├── environments
	 │   ├── development
	 │   │   └── templates
	 │   │
	 │   ├── production
	 │   │   └── templates
	 │   │
	 │   ... more environments here...
	 │
	 ├── globals
	 │
	 └── templates
	     ├── mongod.erb
	     │   ├── content
	     │   ├── target_values
	     │   │   ├── development
	     │   │   └── production
	     │   └── values
	     │       ├── development
	     │       └── production
	     │
	     ... more templates here ...

This also has the advantage that it is easy to implement using flat files. So, you can obtain the values for the "mongod.erb" template in the development environment via `http://tiller.example.com/tiller/templates/mongod.erb/values/development`. An example curl request (piped through [jq](http://stedolan.github.io/jq/) for formatting) might look like :

```
$ curl http://tiller.example.com/tiller/templates/mongod.erb/values/development | jq .
{
	"repl_set_name" : "dev_replset",
	"storage_engine" : "wiredTiger",
	...
	... more values here
	...
}

```

The paths specified for any of the parameters listed above may include the following placeholders :

* `%e` : This will be replaced with the value of the current environment
* `%t` : This will be replaced with the value of the current template

There are 5 parameters that tell Tiller where to look for templates and values from your webserver :

* `templates` : where to find the list templates of templates for the given environment. This URL should return a JSON array of templates, e.g. `[ "mongodb.erb" , "another_template.erb" , .... ]`
* `template_content` : where to fetch the actual template content. This is expected to be returned as plain text, whereas the other paths should return structured data (currently only JSON format is supported) 

The following whould all return a JSON hash of `key:value` pairs (see above for an example):

* `values.global` : where to find the global values that are the usually the same across all environments and templates. 
* `values.template` : where to find values for a specific template. 
* `values.target` : where to find target values for a specific template, e.g. the path it should be installed to, the owner and permissions and so on. 

So, if you wanted to fetch your template values using a scheme such as `'http://tiller.example.com/tiller/values.php?template=mongodb.erb&environment=production'`, you could use something like:

```yaml
 http: 
   values:
     template: '/tiller/values.php?template=%t&environment=%e'
```

