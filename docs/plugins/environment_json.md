# Environment JSON Plugin
If you add `environment_json` to your list of data sources in `common.yaml`, you'll be able to make complex JSON data structures available to your templates. Just pass your JSON in the environment variable `tiller_json`. See [http://www.markround.com/blog/2014/10/17/building-dynamic-docker-images-with-json-and-tiller-0-dot-1-4/](http://www.markround.com/blog/2014/10/17/building-dynamic-docker-images-with-json-and-tiller-0-dot-1-4/) for some practical examples.

As of Tiller 0.7.6, you can use this to also handle per-template variables, instead of treating everything as a "global" variable. To do this, make sure you have a key `_version` with a value of `2`. You can then separate values into global and per-template blocks, for example :

```json
{
  "_version" : 2,
  "global" : {
    "global_value" : "This is a global value available to all templates"
  },
  "template.erb" : {
    "local_value" : "This will create the 'local_value' only on template.erb"
  }
}
```

