# Separate configuration files per environment

Instead of placing all your environment configuration in `common.yaml`, you can split environment definitions out into separate files. This was the default behaviour of Tiller < 0.7.0, although it  will remain supported in future versions. To do this, create a `/etc/tiller/environments` directory, and then a yaml file named after your environment. 

For example, consider a `/etc/tiller/common.yaml` that had a block like this:
 
```yaml
environments:
  staging:
    mongodb.erb:
    	target: /etc/mongodb.conf
    	user: root
    	group: root
    	perms: 0644
    	config:
    		replSet: 'staging'
   production:
    ... rest of content snipped ...
``` 
 
You would create a `/etc/tiller/environments/staging.yaml` file with the following content:

```yaml
mongodb.erb:
	target: /etc/mongodb.conf
	user: root
	group: root
	perms: 0644
	config:
		replSet: 'staging'
```
And so on, one for each environment. You would then remove the `environments:` block from `common.yaml`, and Tiller will switch to loading these individual files.

# Separate config files under config.d

If you want to further split out your configuration, you can create a `config.d` directory (usually at `/etc/tiller/config.d`) and place configuration fragments in separate YAML files under it. All these files will be loaded in order and merged together. Any configuration variable or block that would normally go in `common.yaml` can be split out into these separate files.

This is particularly useful for creating layered Docker images which inherit from a base. The base image could contain your default Tiller configuration, and you can then drop additional files under `config.d` to over-ride the defaults, or to specify new templates for that particular container.

See the [test fixture](https://github.com/markround/tiller/blob/master/features/config_d.feature) for some examples.