There is a HTTP API provided for debugging purposes. This may be useful if you want a way of extracting and examining the configuration from a running container. Note that this is a *very* simple implementation, and should never be exposed to the internet or untrusted networks. Consider it as a tool to help debug configuration issues, and nothing more. 

# Enabling
You can enable the API by passing the `--api` (and optional `--api-port`) command-line arguments. Alternatively, you can also set these in `common.yaml` :
	
```yaml
api_enable: true
api_port: 6275
```

# Usage
Once Tiller has forked a child process (specified by the `exec` parameter), you will see a message on stdout informing you the API is starting :

	Tiller API starting on port 6275
	
If you want to expose this port from inside a Docker container, you will need to add this port to your list of mappings (e.g. `docker run ... -p 6275:6275 ...`). You should now be able to connect to this via HTTP, e.g.

```
$ curl -D - http://docker-container-ip:6275/ping
HTTP/1.1 200 OK
Content-Type: application/json
Server: Tiller 1.0.0 / API v2

{ "ping": "Tiller API v2 OK" }

```

# Methods
The API responds to the following GET requests:

* **/ping** : Used to check the API is up and running.
* **/v2/config** : Return a hash of the Tiller configuration.
* **/v2/templates** : Return a list of generated templates.
* **/v2/template/{template_name}** : Return a hash of merged values and target values for the named template.
