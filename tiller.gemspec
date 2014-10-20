gem 'tiller', :git => 'git://github.com/markround/tiller.git'

Gem::Specification.new do |s|
  s.name = 'tiller'
  s.version = '0.2.2'
  s.date = '2014-10-20'
  s.summary = 'Dynamic configuration generation for Docker'
  s.description = 'A tool to create configuration files in Docker containers from a variety of sources. See https://github.com/markround/tiller for examples and documentation.'
  s.authors = ['Mark Round']
  s.email = 'github@markround.com'
  s.files = %w(
    lib/tiller/api.rb
    lib/tiller/api/handlers/404.rb
    lib/tiller/api/handlers/ping.rb
    lib/tiller/api/handlers/config.rb
    lib/tiller/api/handlers/globals.rb
    lib/tiller/api/handlers/templates.rb
    lib/tiller/api/handlers/template.rb
    lib/tiller/datasource.rb
    lib/tiller/templatesource.rb
    lib/tiller/data/file.rb
    lib/tiller/data/environment.rb
    lib/tiller/data/environment_json.rb
    lib/tiller/data/random.rb
    lib/tiller/template/file.rb
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
  )
  s.executables << 'tiller'
  s.homepage =
      'http://www.markround.com'
  s.license = 'MIT'
  s.metadata = { 'source' => 'https://github.com/markround/tiller' }
end
