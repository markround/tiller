# External File Plugin
This plugin lets you load an external JSON or YAML file, and return its contents to your templates as global values. You may find this useful for allowing an end user to configure a docker container which requires lots of parameters; thereby avoiding the need for lots of environment variables and unwieldy `docker run` commands.

The plugin is enabled by adding `external_file` to the list of datasources in your `common.yaml`, and then providing a list of absolute file paths :

```yaml
data_sources: [ "file" , "external_file" ]
external_files:
  - /config/external.yaml
  - /config/external.json
```

These could be provided by an end-user, and passed into the Docker container by way of volumes :

`docker run -ti -v /config:/config ......`

See the [test fixture](https://github.com/markround/tiller/tree/master/features/fixtures/external_file) for a full example.

