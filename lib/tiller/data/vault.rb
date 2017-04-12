require 'yaml'
require 'vault'
require 'tiller/datasource'
require 'tiller/vault.rb'

class VaultDataSource < Tiller::DataSource

  include Tiller::VaultCommon

  def global_values
    return {} unless Tiller::config.has_key?('vault')
    if @vault_config['flex_mode']
      globals = {}
      Tiller::log.debug("#{self} : In Flex Mode: Fetching all defined paths under values")
      @vault_config['values'].each do |key, path|
        next unless path
        Tiller::log.debug("#{self} : Fetching values in #{path} into the #{key} variable")
        path = "/#{path}" if path[0] != '/'
        path = interpolate(path)
        globals[key] = get_values(path)
      end
      globals
    else
      path = interpolate("#{@vault_config['values']['global']}")
      Tiller::log.debug("#{self} : Fetching globals from #{path}")
      globals = get_values(path)

      # Do we have per-env globals ? If so, merge them
      path = interpolate("#{@vault_config['values']['per_env']}")
      Tiller::log.debug("#{self} : Fetching per-environment globals from #{path}")
      globals.deep_merge!(get_values(path))
    end
  end

  def values(template_name)
    return {} unless Tiller::config.has_key?('vault')
    if @vault_config['flex_mode']
      # Merge configs of the template and environment, subsequently
      template_config = Tiller::config[template_name] || {}
      if Tiller::config.has_key?('environments') && Tiller::config['environments'].has_key?(Tiller::config[:environment]) && Tiller::config['environments'][Tiller::config[:environment]].has_key?(template_name)
        template_config.deep_merge!(Tiller::config['environments'][Tiller::config[:environment]][template_name])
      end
      return {} unless template_config.has_key?('vault')
      values = {}
      template_config['vault'].each do |key, path|
        path = "/#{path}" if path[0] != '/'
        # We want to make Vault compatible with dynamic values here
        path = Tiller::render(path, direct_render: true) if Tiller::config.assoc('dynamic_values')
        path = interpolate(path)
        Tiller::log.debug("#{self} : Fetching values in #{path} into the #{key} variable")
        values[key] = get_values(path)
      end
      values
    else
      path = interpolate("#{@vault_config['values']['template']}", template_name)
      Tiller::log.debug("#{self} : Fetching template values from #{path}")
      get_values(path)
    end
  end


  def target_values(template_name)
    return {} unless Tiller::config.has_key?('vault')
    return {} if @vault_config['flex_mode']
    path = interpolate("#{@vault_config['values']['target']}", template_name)
    Tiller::log.debug("#{self} : Fetching template target values from #{path}")
    get_values(path)
  end


  # Helper method, not used by DataSource API
  def get_values(path)
    keys = nil
    Tiller::log.debug("Trying Vault list with #{path}")
    Vault.with_retries(Vault::HTTPConnectionError, Vault::HTTPError) do |attempt, e|
      Tiller::log.warn("#{self} : Received exception #{e} from Vault") if e
      keys = Vault.logical.list(path)
    end

    values = {}
    if keys.is_a?(Array) && keys.size > 0
      keys.each do |k|
        Tiller::log.debug("#{self} : Fetching value at #{path}/#{k}")
        Vault.with_retries(Vault::HTTPConnectionError, Vault::HTTPError) do |attempt, e|
          Tiller::log.warn("#{self} : Received exception #{e} from Vault") if e
          Tiller::log.debug("Actual Vault Path: #{File.absolute_path(k,path)}")
          vdata = Vault.logical.read(File.absolute_path(k,path)).data
          if @vault_config['flex_mode']
            values[k.to_sym] = vdata
          else
            values[k] = vdata[@vault_config['json_key_name']]
          end
        end
      end
      values
    elsif @vault_config['flex_mode']
      Tiller::log.debug("#{path} is likely a Vault document, retrieving values for them")
      Vault.with_retries(Vault::HTTPConnectionError, Vault::HTTPError) do |attempt, e|
        Tiller::log.warn("#{self} : Received exception #{e} from Vault") if e
        vault_data = Vault.logical.read(path)
        if vault_data && (data = vault_data.data) && data.is_a?(Hash)
          values = data
        else
          Tiller::log.warn("No values found at #{path}")
        end
      end
      values
    else
      {}
    end
  end


end
