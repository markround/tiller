# Environment Nested Plugin
If you add `environment_nested` to your list of data sources in `common.yaml`, you'll be able to create or overwrite nested configuration variables.

```yaml
data_sources: [ "defaults", "file", "environment_nested" ]
template_sources: [ "file" ]

defaults:
  global:
    restapi:
      server:
        port: 80
```

Setting environment variable `restapi_server_port=8080` will overwrite value `80` from defaults.

To overwrite large structures it's probably easier to use `environment_json`.

