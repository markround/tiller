# Checksums
You may wish to only write templates to disk if they do not already exist, or if their content has changed. You can pass the `--md5sum` flag on the command line, or set `md5sum: true` in your `common.yaml`. With this feature enabled, you'll see output like this in your logs:

```
[1/2] templates written, [1] skipped with no change
Template generation completed
```
If you pass the debug flag on the command-line (`-d` / `--debug`), you'll see further information like this amongst the output :

```
Building template test.erb
MD5 of test.erb is c377cfd6c73a5a9a334f949503b6e65d
MD5 of test.txt is c377cfd6c73a5a9a334f949503b6e65d
Content unchanged for test.erb, not writing anything
[0/1] templates written, [1] skipped with no change
```

If you also want to make sure a process is launched only if at least one file has been updated, you can pass the `--md5sum-noexec` command line option, or set `md5sum_noexec: true` in your `common.yaml`. 

