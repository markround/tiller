module Tiller

  Defaults = {
    :tiller_base          => (ENV['tiller_base'].nil?)  ? '/etc/tiller' : ENV['tiller_base'],
    :tiller_lib           => (ENV['tiller_lib'].nil?)   ? '/usr/local/lib' : ENV['tiller_lib'],
    # If not specified in environment, leave it as nil, we'll pick it up later
    # from the -e flag or set it to default_environment.
    :environment          => (ENV['environment'].nil?)  ? nil : ENV['environment'],
    # This can be overridden in common.yaml.
    'default_environment' => 'development',
    :no_exec              => false,
    :verbose              => false,
    'api_enable'          => false,
    'api_port'            => 6275
  }

end

# Defaults for the Zookeeper data and template sources
module Tiller::Zookeeper

  Defaults = {
    'timeout'   => 5,
    'templates' => '/tiller/%e',

    'values'    => {
        'global'    => '/tiller/globals',
        'template'  => '/tiller/%e/%t/values',
        'target'    => '/tiller/%e/%t/target_values'
    }
  }

end


# Defaults for the HTTP data and template sources
module Tiller::Http

  Defaults = {
      'timeout'   => 5,
      'proxy'     => '',
      'templates' => '/tiller/templates',
      'template_content' => '/tiller/%t/content',
      'parser'    => 'json',

      'values'    => {
          'global'    => '/tiller/globals',
          'template'  => '/tiller/%t/values/%e',
          'target'    => '/tiller/%t/target_values/%e'
      }
  }

end

