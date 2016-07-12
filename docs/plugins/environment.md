# Environment Plugin
If you add `environment` to the list of data sources in `common.yaml`, you'll be able to access environment variables within your templates. These are all converted to lower-case, and prefixed with `env_`. So for example, if you had the environment variable `LOGNAME` set, you could reference this in your template with `<%= env_logname %>`

