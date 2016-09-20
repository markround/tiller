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
    'md5sum'              => false,
    'md5sum_noexec'       => false,
    'deep_merge'          => false,
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

# Defaults for the Vault data and template sources
module Tiller::Vault
  Defaults = {
    'timeout'       => 30,
    'ssl_verify'    => false,
    'templates'     => '/secret/tiller/templates',
    'json_key_name' => :content,

    'values'    => {
        'global'    => '/secret/tiller/globals/all',
        'per_env'   => '/secret/tiller/globals/%e',
        'template'  => '/secret/tiller/values/%e/%t',
        'target'    => '/secret/tiller/target_values/%t/%e'
    }
  }
end

# Defaults for the HTTP data and template sources
module Tiller::Http
  def self.defaults
    {
      'timeout'   => 5,
      'proxy'     => '',
      'templates' => '/tiller/environments/%e/templates',
      'template_content' => '/tiller/templates/%t/content',
      'parser'    => 'json',

      'values'    => {
          'global'    => '/tiller/globals',
          'template'  => '/tiller/templates/%t/values/%e',
          'target'    => '/tiller/templates/%t/target_values/%e'
      }
    }
  end
end

module Tiller::Consul
  def self.defaults
    {
      'dc'                => 'dc1',
      'acl_token'         => nil,
      'register_services' => false,
      'register_nodes'    => false,

      'templates' => '/tiller/templates',

      'values'    => {
          'global'    => '/tiller/globals/all',
          'per_env'   => '/tiller/globals/%e',
          'template'  => '/tiller/values/%e/%t',
          'target'    => '/tiller/target_values/%t/%e'
      }
    }
  end
end

module Tiller::Environment
  def self.defaults
    {
        'prefix'    => 'env_',
        'lowercase' => true
    }
  end
end

module Tiller::AnsibleVault
  def self.defaults
    {
        'vault_password_env'  => 'ANSIBLE_VAULT_PASS'
    }
  end
end
