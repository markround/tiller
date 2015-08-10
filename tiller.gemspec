Gem::Specification.new do |s|
  s.name = 'tiller'
  s.version = '0.6.5'
  s.date = '2015-08-07'
  s.summary = 'Dynamic configuration file generation'
  s.description = 'A tool to create configuration files from a variety of sources, particularly useful for Docker containers. See https://github.com/markround/tiller for examples and documentation.'
  s.authors = ['Mark Dastmalchi-Round']
  s.email = 'github@markround.com'
  s.files = %w(
    lib/tiller/api.rb
    lib/tiller/api/handlers/404.rb
    lib/tiller/api/handlers/ping.rb
    lib/tiller/api/handlers/config.rb
    lib/tiller/api/handlers/globals.rb
    lib/tiller/api/handlers/templates.rb
    lib/tiller/api/handlers/template.rb
    lib/tiller/loader.rb
    lib/tiller/options.rb
    lib/tiller/util.rb
    lib/tiller/defaults.rb
    lib/tiller/datasource.rb
    lib/tiller/json.rb
    lib/tiller/http.rb
    lib/tiller/templatesource.rb
    lib/tiller/data/file.rb
    lib/tiller/data/zookeeper.rb
    lib/tiller/data/http.rb
    lib/tiller/data/environment.rb
    lib/tiller/data/environment_json.rb
    lib/tiller/data/random.rb
    lib/tiller/data/defaults.rb
    lib/tiller/template/file.rb
    lib/tiller/template/zookeeper.rb
    lib/tiller/template/http.rb
    examples/plugins/etc/tiller/common.yaml
    examples/plugins/etc/tiller/environments/production.yaml
    examples/plugins/etc/tiller/environments/staging.yaml
    examples/plugins/etc/tiller/templates/sensu_client.erb
    examples/plugins/lib/tiller/data/dummy.rb
    examples/plugins/lib/tiller/data/network.rb
    examples/plugins/lib/tiller/template/dummy.rb
    examples/json/common.yaml
    examples/json/environments/array.yaml
    examples/json/environments/simple_keys.yaml
    examples/json/templates/array.erb
    examples/json/templates/simple_keys.erb
    examples/defaults
    examples/defaults/common.yaml
    examples/defaults/defaults.yaml
    examples/defaults/environments
    examples/defaults/environments/production.yaml
    examples/defaults/environments/staging.yaml
    examples/defaults/templates
    examples/defaults/templates/app.conf.erb
    examples/defaults.d
    examples/defaults.d/common.yaml
    examples/defaults.d/defaults.d
    examples/defaults.d/defaults.d/app.conf.yaml
    examples/defaults.d/defaults.d/global.yaml
    examples/defaults.d/defaults.yaml
    examples/defaults.d/environments
    examples/defaults.d/environments/production.yaml
    examples/defaults.d/environments/staging.yaml
    examples/defaults.d/templates
    examples/defaults.d/templates/app.conf.erb
  )
  s.executables << 'tiller'
  s.homepage =
      'http://www.markround.com'
  s.license = 'MIT'
  s.metadata = { 'source' => 'https://github.com/markround/tiller' }
  s.required_ruby_version = '>= 1.9.2'
end
