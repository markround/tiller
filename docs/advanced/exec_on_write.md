# Running commands per-template

In addition to running a daemon process after the configuration files have been generated (using the `exec:` [parameter](../general/configuration.md#exec)), you can also specify a separate `exec_on_write:` parameter for each template in the `target_values` block. For example, to create a file after a template has been created you can do something like this:

```yaml
---
exec: [ "/usr/sbin/some_daemon" ]
data_sources: [ "file" ]
template_sources: [ "file" ]

environments:
  development:
    test.erb:
      target: test.txt
      exec_on_write: ["touch" , "/tmp/exec_on_write.tmp"]
      config:
        ...
        ... rest of configuration snipped ...
        ...
```

If these are long-running processes, Tiller will also wait for them to complete before exiting, and will also propogate signals such as SIGINT to them. 

However, if you are considering using this feature to spawn additional daemons do consider that Tiller is not intended as a full-blown supervisor/init system. You may want to consider using something like [supervisord](http://supervisord.org) instead. Using Tiller to generate configuration files for multiple processes and then running supervisord through the `exec` parameter is a common use-case.

## Checksums
This feature interacts with the [checksum](checksums.md) feature: When checksums are enabled, if the template has not been written to disk, no `exec_on_write` process will be run. 