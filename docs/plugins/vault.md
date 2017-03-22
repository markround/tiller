# Vault plugins

Tiller includes plugins to retrieve templates and values [Vault](https://www.vaultproject.io) cluster. These plugins rely on the `vault` gem to be present, so before proceeding ensure you have run `gem install vault` in your environment. This is not listed as a hard dependency of Tiller, as this would force the gem to be installed even on systems that would never use these plugins.

# Enabling the plugins
Add the `vault` plugins in your `common.yaml`, e.g.

```yaml
data_sources: [ "vault" ]
template_sources: [ "vault" ]
```

If you're fetching all your values and templates from Vault, those should be the only plugins you need.

However, you do not need to enable both plugins; for example you may just want to retrieve values for your templates from Vault, but continue to use files to store your actual template content. For example :

```yaml
data_sources: [ "vault", "environment" ]
template_sources: [ "file" ]
```

The above example would use templates from files, and retrieve values from Vault first, then try the `environment` plugin.


# Configuring
Configuration for this plugin is placed inside a "vault" block. This should be in the the top-level of `common.yaml` file, or in a [per-environment block](file.md#overriding-common-settings).

A sample configuration (showing the defaults for most parameters) is as follows :

```yaml
vault:
  url: 'https://localhost:8200'
  token: '8313ef8c-0c6f-ca24-2783-ab92f10d7717'
  ssl_verify: false

  templates: '/secret/tiller/templates'
  values:
   global: '/secret/tiller/globals/all'
   per_env: 'secret/tiller/globals/%e'
   template: '/secret/tiller/values/%e/%t'
   target: '/secret/tiller/target_values/%t/%e'
```

At a bare minimum, you need to specify a URL for the plugins to connect to. This is the HTTP port of your Vault server, e.g. `http://localhost:8200`. If you would like to verify the validity of certificate, set `ssl_verify` to `true` and provide path to certificate with `ssl_pem_file`. URL should also be switched to `https`. If you're happy to accept the rest of the defaults, your configuration can therefore be as simple as this :

```yaml
data_sources: [ "vault" ]
template_sources: [ "vault" ]
vault:
  url: 'http://localhost:8200'
```

## Authentication

Vault requires a token in order to connect to it. If you omit the token parameter, Tiller will look for it in your `~/.vault-token` file (which is created automatically when vault is started in dev mode).


```yaml
vault:
  url: 'http://localhost:8200'
  token: '8313ef8c-0c6f-ca24-2783-ab92f10d7717'
```

# Paths
You can use any K/V hierarchy inside Vault, but the default is expected to look like the following:

Since Vault stores documents in JSON with a body like:

```json
{
  "content": "bar"
}
```

by default Tiller will assume that the key name is `content`, however it is configurable with `json_key_name` parameter. If you want it to be stored, for example, as

```json
{
  "value": "bar"
}
```

you can configure Tiller as follows:

```yaml
vault:
  url: 'https://localhost:8200'
  json_key_name: :value
```
	/secret
	  ├──tiller
		 ├── globals
	 	 │   ├── all
	 	 │   │   └── some_key_for_all_environments -> { "content" : "some_configuration_value" }
	 	 │   │
	 	 │   ├── production
	 	 │   │   └── some_key_only_for_production_environment -> { "content" : "some_configuration_value" }
	 	 │   │
	 	 │   ... more environments here...
	 	 │
	 	 ├── templates (each key contains the ERB template as its value)
	 	 │   ├── template1.erb -> { "content" : "template contents..."}
	 	 │   ├── template2.erb -> { "content" : "template contents..."}
	 	 │   ... more templates here ...
	 	 │
	 	 ├── values
	 	 │   ├── production (keys and values for the 'production' environment)
	 	 │   │       ├ template1.erb
	 	 │   │       │     ├── some_key
	 	 │   │       │     ├── some_other_key
     	 │   │       ├ template2.erb
	 	 │   │       │     ├── some_key
	 	 │   │       │     ├── some_other_key
     	 │   │       ...more templates and keys...
 	 	 │   │
 	 	 │   └── development (keys and values for the 'development' environment)
	 	 │           ├ template1.erb
	 	 │           │     ├── some_key
	 	 │           │     ├── some_other_key
     	 │           ├ template2.erb
	 	 │           │     ├── some_key
	 	 │           │     ├── some_other_key
     	 │           ...more templates and keys...
 	 	 │
 	 	 │
    	 └── target_values (controls which templates get installed and where)
	     	├── template1.erb
	     	│   ├── production
	     	│   │       └── target (where to install the template in production)
	     	│   └── development
	     	│           └── target (where to install the template in development)
	     	│
	     	└── template1.erb (don't install template2.erb in development)
	       	  └── production
	                  └── target (where to install the template in production)



You can change this to any structure you like by altering the `templates` and `values` parameters. The paths specified for any of these parameters listed above may include the following placeholders :

* `%e` : This will be replaced with the value of the current environment
* `%t` : This will be replaced with the value of the current template

There is a benefit to keeping this default layout though: if you're using a shared Vault service, it makes it easy to define [ACLs](https://www.vaultproject.io/intro/getting-started/acl.html) so that you can, for example, deny access to the `/values/production` or `/globals/production` paths for non-production services.

# Accessing data from templates

## K/V store
Vault keys and their values will be exposed to templates as regular variables. So, using the example structure above, you could just reference a vault key for your environment/template within your template like so :

```erb
This is a value for template1 : <%= some_key %>
This is a global value : <%= some_key_for_all_environments %>
This should only be present in production : <%= some_key_only_for_production_environment %>
```

# Flex Mode

If you would like to be more precise with your Vault paths, or simply want to access all of the Key/Value pairs in a single Vault document rather than just a single key, you can use `flex_mode`:

```yaml
data_sources: [ "vault" , "file" ]
template_sources: [ "file" ]
dynamic_values: true

vault:
  url: 'http://127.0.0.1:8200'
  flex_mode: true
  values:
    foo: 'secret/custom/foo'
    custom: 'secret/custom'

environments:
  development:
    test.erb:
      target: test.txt
        vault:
          foo: 'secret/%e/foo'
          dynamic_foo: 'secret/<%= environment %>/foo'

test.erb:
  vault:
    all_foo: 'secret/<%= environment %>/foo'
```

You can also use specify a list path in Vault to be used in a mapping, and the plugin will map the listed keys into a symbolized hash.

**NOTE:** Vault cannot be used as a template source when in `flex_mode`. All `values` will be mapped to globals.

You can also make template-specific Vault mappings within the `environments` namespace or top-level namespace, as described above. The environment-specific Vault mappings will override the top-level ones.
