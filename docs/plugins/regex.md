# Regex

This plugin allows develops to take advantage of regular expression functionality to configure container.

# Enabling the plugin
Add the `regex` plugins in your `common.yaml`, e.g.

```yaml
data_sources: [ 'file' ]
template_sources: [ 'regex' ]
```

This plugin leverages tiller template functionality to apply regular expressions on files. All replacements are done while template class is loaded. Therefore all configuration for this plugin needs to be added to `common.yaml` file and `file` data source has to be used.

# Configuring
This plugin does not rely on template name. For this, any unique string can be used followd by `!regex` suffix (this is how plugin identifies its configuration!!!). Plugin uses `target` to locate file. `regex` field has to contain list of values that need to be applied.

Example:

```yaml
environments:
  development:
    file_name!regex:
      target: /path/to/file/temp.txt
      regex:
        - find: before
          replace: after
        - find: '^#some\.comment'
          replace: some_other_comment
```