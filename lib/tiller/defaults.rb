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

