Gem::Specification.new do |s|
  s.name = 'tiller'
  s.version = '0.0.1'
  s.date = '2014-07-18'
  s.summary = 'Dynamic configuration generation for Docker'
  s.description = 'A tool to create configuration files in Docker containers from a variety of sources'
  s.authors = ['Mark Round']
  s.email = 'github@markround.com'
  s.files = %w(
    lib/tiller/datasource.rb
    lib/tiller/templatesource.rb
    lib/tiller/data/file.rb
    lib/tiller/template/file.rb
    examples/etc/tiller/common.yaml
    examples/etc/tiller/environments/production.yaml
    examples/etc/tiller/environments/staging.yaml
    examples/etc/tiller/templates/sensu_client.erb
    examples/lib/tiller/data/dummy.rb
    examples/lib/tiller/data/network.rb
    examples/lib/tiller/template/dummy.rb
  )
  s.executables << 'tiller'
  s.homepage =
      'http://www.markround.com'
  s.license = 'MIT'
end
