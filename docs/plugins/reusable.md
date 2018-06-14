# Reusable

This plugin allows developers to reuse file templates.

# Enabling the plugin
Add the `reusable` plugins in your `common.yaml`, e.g.

```yaml
template_sources:
  - file
  - reusable
```

This plugin allows develops to reuse file templates, therefore `file` plugin has to be enabled as well.

# Configuring
To use this plugin add suffix to template name, e.g. `!123` (! followed by unique number). To identify reusable templates this plugin scans `common.yaml`, therefore all reusable templates have to be listed here. Data can be fetched from other data sources. 

Example:

```yaml
environments:
  development:
    temp.erb!1:
      target: /path/to/file/temp.txt
      config:
        var: first file
    temp.erb!2:
      target: /path/to/file/temp2.txt
      config:
        var: second file
```
