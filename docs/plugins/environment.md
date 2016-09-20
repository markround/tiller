# Environment Plugin
If you add `environment` to the list of data sources in `common.yaml`, you'll be able to access environment variables within your templates. 

By default, these are all converted to lower-case, and prefixed with `env_`. So for example, if you had the environment variable `LOGNAME` set, you could reference this in your template with `<%= env_logname %>`

## Configuration 
As of Tiller 0.7.10, you can specify a custom prefix instead of `env_` by setting the following option in the top-level of your `common.yaml`:

```yaml
environment:
  prefix: 'custom_prefix_'
```

You can also control whether variables are converted to lower-case or not by setting the `lowercase` flag:

```yaml
environment:
  prefix: 'custom_prefix_'
  lowercase: false
```

It is important to note that you most likely can not guarantee which environment variables will be present in your deployment environment. If you set the prefix to `''`, then you will be able to access variables by their original name. For example, `test_var="hello" tiller -v ......` will result in a variable called `test_var` being available to your templates instead of `env_test_var`.

However, any other environment variables will also be made available (`env | wc -l` shows 58 variables defined on my fairly stock Mac OS X system), and they may unexpectedly over-ride your own variables. So you should only use a null prefix for this plugin if you are 100% certain you know in advance what environment variables will be present in your deployment environment.