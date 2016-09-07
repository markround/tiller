require 'yaml'
require 'vault'
require 'tiller/datasource'
require 'tiller/vault.rb'

class VaultDataSource < Tiller::DataSource

  include Tiller::VaultCommon

  def global_values
    return {} unless Tiller::config.has_key?('vault')
    path = interpolate("#{@vault_config['values']['global']}")
    Tiller::log.debug("#{self} : Fetching globals from #{path}")
    globals = get_values(path)

    # Do we have per-env globals ? If so, merge them
    path = interpolate("#{@vault_config['values']['per_env']}")
    Tiller::log.debug("#{self} : Fetching per-environment globals from #{path}")
    globals.deep_merge!(get_values(path))
  end

  def values(template_name)
    return {} unless Tiller::config.has_key?('vault')
    path = interpolate("#{@vault_config['values']['template']}", template_name)
    Tiller::log.debug("#{self} : Fetching template values from #{path}")
    get_values(path)
  end


  def target_values(template_name)
    return {} unless Tiller::config.has_key?('vault')
    path = interpolate("#{@vault_config['values']['target']}", template_name)
    Tiller::log.debug("#{self} : Fetching template target values from #{path}")
    get_values(path)
  end


  # Helper method, not used by DataSource API
  def get_values(path)
    keys = nil
    Vault.with_retries(Vault::HTTPConnectionError, Vault::HTTPError) do |attempt, e|
        Tiller::log.warn("#{self} : Received exception #{e} from Vault") if e
        keys = Vault.logical.list(path)
    end

    values = {}
    if keys.is_a? Array
      keys.each do |k|
        Tiller::log.debug("#{self} : Fetching value at #{path}/#{k}")
        Vault.with_retries(Vault::HTTPConnectionError, Vault::HTTPError) do |attempt, e|
            Tiller::log.warn("#{self} : Received exception #{e} from Vault") if e
            values[k] = Vault.logical.read(File.absolute_path(k,path)).data[@vault_config['json_key_name']]
        end
      end
      values
    else
      {}
    end
  end


end
