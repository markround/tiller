# Quickstart tutorial
The following examples are intended to give you a very quick overview of how Tiller can generate dynamic configuration files, using values from a few different [plugins](plugins/index.md). It doesn't cover topics like executing commands and running Tiller inside Docker, however this is covered in the rest of the documentation. The example simplistic use-case covered is an application that has a database configuration file, and we need a way to set the database hostname dynamically, depending on where the application is run.  


# Requirements
 * Ruby >= 1.9 (2.x series preferred, 2.3 is ideal)
 * "gem" command (usually provided as part of your operating system's Ruby packages)
 
# Setup

Install Tiller:
```
$ gem install tiller 
```

Create the necessary work directories:
```sh
$ mkdir quickstart
$ mkdir quickstart/templates
```

Create a simple template file and save it as `quickstart/templates/db.erb` - this is your example database configuration file.

```erb 
db_hostname: <%= env_db_hostname %>
```

# Example 1 : Provide value from environment
Create a file named `quickstart/common.yaml` with the following content:

```yaml
---
data_sources: [ "file" , "environment" ]
template_sources: [ "file" ]
environments:
  development:
    db.erb:
      target: db.ini
```

The `common.yaml` configuration loads the File plugin so Tiller can parse the rest of the configuration, and also enables the Environment plugin. This by default makes all environment variables available to templates, and prefixes them with `env_` and converts them to lower-case.

Now, set the environment variable and run Tiller, pointing it to your `quickstart` directory for loading its configuration files :

```sh
$ export DB_HOSTNAME=mydb.example.com
$ tiller --base-dir=./quickstart
```

Now, your template file has been written to `db.ini` (specified by the `target:` parameter in the main configuration file) and has the content set from your environment variable:

```ini
db_hostname: mydb.example.com
```

** Further work **

 * Read the documentation for the [Environment plugin](plugins/environment.md) and set some of the parameters it provides such as `prefix` and `lowercase` and see how this changes your template. 
 * Try adding the `-d` and `-v` flags when you run Tiller (e.g. `tiller --base-dir=./quickstart -v`)to see how this provides extra information. 

# Example 2 : Provide a default value

Modify your `common.yaml` so it now has the following content:

```yaml
---
data_sources: [ "file" , "defaults", "environment" ]
template_sources: [ "file" ]

defaults:
  global:
    env_db_hostname: localhost
    
environments:
  development:
    db.erb:
      target: db.ini
```

This now enables the [Defaults](plugins/defaults.md) plugin and configures it to provide a default value if one is not set. Try unsetting the environment variable you set earlier and re-running Tiller :

```sh
$ unset DB_HOSTNAME
$ tiller --base-dir=./quickstart
```

Now your generated file "db.ini" should contain:

```ini
db_hostname: localhost
```

** Further work **

 * Try swapping the order that the data sources are loaded in the `data_sources:` parameter and re-run the tiller command. What happens ? Why ? Hint: [the plugins documentation](plugins/#ordering).
 
# Example 3 : Provide pre-defined environments for your config

Let's suppose that you know in advance what the values for the `db_hostname` should be, when the environment is run in your "production" and "staging" environments, but you still want the ability to specify the value when you are developing locally or to provide a manual override in any environment. You can achieve this by specifying environments, and telling Tiller which one to use at run-time.

Modify your `common.yaml` so that it now reads:

```yaml
---
data_sources: [ "defaults" , "file", "environment" ]
template_sources: [ "file" ]

defaults:

  global:
    env_db_hostname: localhost
    
  db.erb:
    target: db.ini
    
environments:
  development:
  
  production:
    db.erb:
      config:
        env_db_hostname: db.prod.example.com
    
  staging:
    db.erb:
      config:
        env_db_hostname: db.staging.example.com
```

In addition to declaring a global default for `env_db_hostname`, this also sets a default for the `target` value of the `db.erb` template - this has the effect of ensuring this template is generated in every environment, and saves a bit of redundancy so we don't have to set this value multiple times.

We then specify an empty "development" environment as we've specified everything we need for this environment already: We have a default value for the database hostname, the template will be generated, and we can override the default by setting an environment variable.

If we run Tiller now in verbose mode:

```sh
$ tiller --base-dir=./t/quickstart -v
```

You'll see in the output the line `Using environment development`, which shows Tiller uses the `development` environment if you don't manually specify one. Therefore, your config file will again look like :

```ini
db_hostname: localhost
```

Now, re-run Tiller but tell it to use the `production` environment and specify you want verbose output:

```sh
$ tiller --base-dir=./quickstart --environment production --verbose
```

You should see the following in the output from Tiller:
```
Merging duplicate data values
env_db_hostname => 'localhost' being replaced by : 'db.prod.example.com' from FileDataSource
```
Which shows the precedence system - the `file` plugin was loaded after `defaults`, so the value specified in the environment block takes priority. Although, as the `environment` plugin is loaded last, you can still override all of these:

```sh
$ db_hostname=mydb tiller --base-dir=./t/quickstart --environment production --verbose
```

And you'll see the following output:

```
Merging duplicate data values
env_db_hostname => 'localhost' being replaced by : 'db.prod.example.com' from FileDataSource
env_db_hostname => 'db.prod.example.com' being replaced by : 'mydb' from EnvironmentDataSource
```

And sure enough, the generated file now contains:

```ini
db_hostname: mydb
```

# Further reading

Hopefully, this gave you a helpful overview of how Tiller works. You may now want to:
 
 * Read the [Set up with Docker](general/docker.md) to see how this can help you build containers with dynamic configuration
 * Continue with the [rest of the documentation](general/index.md)
 * See what [plugins](plugins/index.md) are available to help you generate your files
 * Or browse some of the [other resources](resources.md)