# Gotchas
This section covers some of the most frequently encountered issues.

## Plugin ordering
See the [Plugin documentation](../plugins/index.md#ordering). Short version: "A template value will take priority over a global value, and a value from a plugin loaded later will take priority over any previously loaded plugins."

## Merging values
Tiller will merge values from all sources - this is intended, as it allows you to over-ride values from one plugin with another. However, be careful as this may have undefined results. Particularly if you include two data sources that each provide target values - you may find that your templates end up getting installed in locations you didn't expect, or containing spurious values!

The default merging behaviour is to **replace** values with ones from a higher priority plugin. However, if you wish instead to merge hash structures, then you can set `deep_merge: true` in `common.yaml`.

For example, the default behaviour without `deep_merge`:

```yaml
---
data_sources: ["defaults","file"]
template_sources: ["file"]
defaults:
  global:
    test_var:
      key1: "key1 from defaults"
      key2: "key2 from defaults"

environments:
  development:
    global_values:
      test_var:
        key1: "key1 from development environment"
```

Will result in a `test_var` value with the following structure (the hash from the defaults plugin has been completely replaced):

```ruby
{"key1"=>"key1 from development environment"}
```

Setting `deep_merge: true` will instead result in a `test_var` with keys merged:

```ruby
{ 
  "key1"=>"key1 from development environment", 
  "key2"=>"key2 from defaults"
}
```

## Empty config
If you are using the file datasource with Tiller < 0.2.5, you must provide a config hash, even if it's empty (e.g. you are using other data sources to provide all the values for your templates). For example:

```yaml
my_template.erb:
  target: /tmp/template.txt
  config: {}
```

Otherwise, you'll probably see an error message along the lines of :

```
/var/lib/gems/1.9.1/gems/tiller-0.2.4/bin/tiller:149:in `merge!': can't convert nil into Hash (TypeError)
```

After 0.2.5, you can leave the config hash out altogether if you are providing all your values from another data source (or don't want to provide any values at all).

## ERb newlines
By default, ERb will insert a newline character after a closing `%>` tag. You may not want this, particularly with loop constructs. As of version 0.1.5, you can suppress the newline using a closing tag prefixed with a `-` character, e.g. 

```erb
<% things.each do |thing| -%>
	<%= thing %>
<% end -%>
```
You may also need tell your editor to use Unix-style line endings. For example, in VIM :

	:set fileformat=unix

## API Encoding::UndefinedConversionError exceptions
This seems to crop up mostly on Ruby 1.9 installations, and happens when converting ASCII-8BIT strings to UTF-8. A workaround is to install the 'Oj' gem, and Tiller will use this if it's found. I didn't make it a hard dependency of Tiller as Oj is a C-library native extension, so you'll need a bunch of extra packages which you may consider overkill on a Docker container. E.g. on Ubuntu, you'll need `ruby-dev`, `make`, a compiler and so on. But if you have all the dependencies, a simple `gem install oj` in your Dockerfile or environment should be all you need.

## Signal handling
Not a "gotcha" as such, but worth noting. Since version 0.4.0, Tiller catches the `INT`,`TERM` and `HUP` signals and passes them on to the child process spawned through `exec`. This makes sure that if Tiller is killed then the child process should also cleanly exit.