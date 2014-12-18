module Tiller

  Defaults = {
    :tiller_base  => (ENV['tiller_base'].nil?)  ? '/etc/tiller' : ENV['tiller_base'],
    :tiller_lib   => (ENV['tiller_lib'].nil?)   ? '/usr/local/lib' : ENV['tiller_lib'],
    # This is the main variable, usually the only one you pass into Docker.
    :environment  => (ENV['environment'].nil?)  ? 'production' : ENV['environment'],
    :no_exec      => false,
    :verbose      => false,
    'api_enable'  => false,
    'api_port'    => 6275
  }

end