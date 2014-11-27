# Changelog

* 0.2.5 : Minor code cleanup, allow config hash to be null in environments
* 0.2.4 : Bug fix case of 'Oj' gem
* 0.2.3 : Catch Exceptions in API accept loop, dump JSON using Oj gem if it's installed, which resolves various `Encoding::UndefinedConversionError` problems.
* 0.2.2 : API Bind to all addresses, otherwise won't work in Docker container.
* 0.2.0 : Added HTTP API for querying status of Tiller from within a running container. Modified fork behaviour so that Tiller now spawns a child process and waits on it, so that the API can continue to run in a separate thread. Tidied up internal data structures (`common_config` now merged into main `config` hash).
* 0.1.5 : Added newline suppression option to ERb templates with the `-%>` closing tag, mimicking Rails behaviour.
* 0.1.4 : Added new command-line arguments -b, -l and -e which can be used to set tiller_base, tiller_lib and environment, instead of using the environment variables. Also added environment_json data source; see [http://www.markround.com/blog/2014/10/17/building-dynamic-docker-images-with-json-and-tiller-0-dot-1-4/](http://www.markround.com/blog/2014/10/17/building-dynamic-docker-images-with-json-and-tiller-0-dot-1-4/)
* 0.1.3 : Added "no exec" feature and command-line arguments -n, -v, and -h. Made output less verbose by default.
* 0.1.2 : Code cleanup based on input from RuboCop
* 0.1.1 : Very minor code cleanup
* 0.1.0 : Modified plugin API slightly by creating a `setup` hook which is called after the plugin is initialized. This could be useful for connecting to a database, parsing configuration files or setting up other data structures.
* 0.0.8 : Added `RandomDataSource` that wraps Ruby's `SecureRandom` class to provide UUIDs, random Base64 encoded data and so on.
* 0.0.7 : Added `EnvironmentDataSource`, so you can now use environment variables in your templates, e.g. `<%= env_user %>`. See [http://www.markround.com/blog/2014/08/04/tiller-v0-dot-0-7-now-supports-environment-variables/](http://www.markround.com/blog/2014/08/04/tiller-v0-dot-0-7-now-supports-environment-variables/) for a very quick overview.

