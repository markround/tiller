# Zookeeper plugins

As of version 0.6.0, Tiller includes plugins to retrieve templates and values from a [Zookeeper](http://zookeeper.apache.org/) cluster. These plugins rely on the `zk` gem to be present, so before proceeding ensure you have run `gem install zk` in your environment. This is not listed as a hard dependency of Tiller in it's gemspec, as this would force the gem to be installed even on systems that would never use these plugins.
 

# Enabling the plugin
Add the `zookeeper` plugins in your `common.yaml`, e.g.

```yaml 
data_sources:
  - file
  - zookeeper
template_sources:
  - zookeeper
  - file
```

Note that the ordering is significant. In the above example, values from the Zookeeper data source will take precedence over YAML files, but templates loaded from files will take precedence over templates stored in Zookeeper. You should tweak this as appropriate for your environment.

You also do not need to enable both plugins; for example you may just want to retrieve values for your templates from zookeeper, but continue to use files to store your actual template content.

# Configuring
Configuration for this plugin is placed inside a "zookeeper" block; this can either be included in the main `common.yaml` file, or in a per-environment file inside the `common` block. See the main [README.md](https://github.com/markround/tiller/blob/master/README.md#common-configuration) for more information on this. 

A sample configuration (showing the defaults for most items) is as follows :
```yaml
 zookeeper:
   uri: 'zk.example.com:2181'
   timeout: 5
   templates: '/tiller/%e'
   values:
     global: '/tiller/globals'
     template: '/tiller/%e/%t/values'
     target: '/tiller/%e/%t/target_values'
```

At a bare minimum, you need to specify a URI for the plugins to connect to. This takes the form of a standard Zookeeper connection string (as understood by the ZK gem). For example :

* `server1:2181` : connection to a single server
* `server1:2181/tiller` : connection to a single server with a chroot
* `server1:2181,server2:2181,server3:2181` : connection to multiple servers (a cluster)
* `server1:2181,server2:2181,server3:2181/tiller` : connection to multiple servers with a chroot

The default timeout is 5 seconds; if a connection to a Zookeeper server/cluster takes longer than this, the connection will abort and Tiller will stop with an exception.

Note that as you can specify `common:` blocks in each environment file, you can specify a different URI per environment. If you do not specify any of the other parameters (`timeout`,`templates` and so on), they will default to the values shown above. These will be explained in the next section.

# Paths

There are 4 configuration items that tell Tiller where to look for templates and values inside your Zookeeper cluster. As Zookeeper is a hierarchical store, these "nodes" can be thought of as directories in a filesystem. The default expected structure is as follows, using MongoDB configuration as an example again :

 	   /tiller
 	    ├── globals
	    │   ├── some_global_value
	    │   ├── another_global_value
	    │   ...
	    │   ... other global values defined here
	    │   ...
	    │
	    ├── dev (templates and values for your "dev" environment)
	    │   ├── mongodb.erb (can also contain the template content if using the template plugin)
	    │   │   ├── values
	    │   │   │    └── replSet (contains the replicaset name for your dev environment)
	    │   │   └── target_values
	    │   │        ├── target (contains the path for the file, e.g. "/etc/mongod.conf")
	    │   │        ├── perms (contains the permissions for the file, e.g. 0644)
	    │   │        ...
	    │   │        ... Other target values go here
	    │   │        ... 
	    │   ...
	    │   ... Other templates for this environment go here
	    │   ...
	    ├── prod (templates and values for your "prod" environment)
	    │   ├── mongodb.erb 
	    ...
	    ... Other environments go here
	    ...

So, you can obtain the replSet value for the mongod.erb template in the dev environment via `/tiller/dev/mongod.erb/values/replSet`. An example zkCli.sh session follows :

```
[zk: localhost:2181(CONNECTED) 1] ls /tiller/dev
[mongod.erb, test.erb]
[zk: localhost:2181(CONNECTED) 2] get /tiller/dev/mongod.erb/values/replSet
development
cZxid = 0x2ec
ctime = Wed May 20 11:53:27 BST 2015
mZxid = 0x2ed
...
...
...
```
The following screenshot using the ZooInspector GUI illustrates how a template node can also contain the template content:
![Zooinspector screenshot](zooinspector.png)

You can however change this hierarchy to suit your environment or working practices.

The paths may include the following placeholders :

* `%e` : This will be replaced with the value of the current environment
* `%t` : This will be replaced with the value of the current template

So, if you instead wanted your templates under the top-level /tiller directory, and then have values grouped by environment under them (e.g. `/tiller/mongodb.erb/values/dev/replSet`), you could specify the following configuration :

```yaml
 zookeeper:
   uri: 'zk.example.com:2181'
   timeout: 5
   templates: '/tiller'
   values:
     global: '/tiller/globals'
     template: '/tiller/%t/values/%e'
     target: '/tiller/%t/target_values/%e'
```





    






