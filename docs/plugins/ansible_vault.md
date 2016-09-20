# Ansible Vault plugin

As of version 0.9.4, Tiller includes a plugin that lets you to retrieve values from an encrypted [Ansible Vault](http://docs.ansible.com/ansible/playbooks_vault.html) YAML file. 

This plugin relies on the `ansible-vault` gem to be present, so before proceeding ensure you have run `gem install ansible-vault` in your environment. This is not listed as a hard dependency of Tiller, as this would force the gem to be installed even on systems that would never use these plugins. 

This gem also requires requires at least Ruby 2.1.0 to run, if you don't have this available, you'll see an error message on startup, and Tiller will exit.

# Enabling the plugins

Add the `ansible_vault` plugin to your list of data sources in your `common.yaml`, e.g.

```yaml
data_sources: [ "file" , "ansible_vault" ]
```

# Configuring the plugin

This plugin requires two pieces of configuration inside a `ansible_vault:` block in `common.yaml`: 


* The location of the encrypted vault file, 
* A passphrase to decrypt it. 
 
The location is specified by the `vault_file` parameter, e.g.

```yaml
ansible_vault:
  vault_file: /data/vault.yml.enc
```

If you are using Tiller inside a Docker container, you can bundle this encrypted file inside the container, or provide it at run-time via Docker volumes (e.g. `docker run -v ./vault.yml.enc:/data/vault.yml.enc ...`)

To decrypt the file, you will need to provide the passphrase. This plugin provides 3 mechanisms for doing this, of which you can only use one at a time for each environment.

## Password in common.yaml

A clear-text password can be provided in the `common.yaml` configuration file. Obviously, this is not in anyway secure, but may be useful for testing and development environments. You simply provide the `vault_password` parameter to the plugin:

```yaml
ansible_vault:
  vault_file: /data/vault.yml.enc
  vault_password: tiller
```

## Password from a file

You can also provide the password stored in a file. This is a little more secure, as it allows you to separate the keyfile from the encrypted file, and provide it at runtime - perhaps by using Docker volumes to make it accessible to a container. To do this, provide the `vault_password_file` parameter:

```yaml
ansible_vault:
  vault_file: /data/vault.yml.enc
  vault_password_file: password.txt
```

## Password from an environment variable

This is the preferred method of providing the passphrase to decrypt the vault file. 

If you don't specify any other configuration apart from the location of the vault file, the plugin will use the value of the environment variable `ANSIBLE_VAULT_PASS` as a passphrase. This means you can pass this in as a variable when you create the Docker container, or test manually:

`$ ANSIBLE_VAULT_PASS="tiller" tiller -v -e development .........`

If you wish to use a different environment variable name, you can configure this with the `vault_password_env` parameter. For example, the following configuration will make the plugin use the contents of the environment variable `MY_PASSWORD` to decrypt the file:

```yaml
ansible_vault:
  vault_file: /data/vault.yml.enc
  vault_password_env: MY_PASSWORD
```
