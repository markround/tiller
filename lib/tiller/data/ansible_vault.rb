require 'ansible/vault'
require 'tiller/util'
require 'yaml'
require 'pp'

class AnsibleVaultDataSource < Tiller::DataSource

  def setup

    @ansible_vault_config = Tiller::AnsibleVault.defaults

    unless Tiller::config.has_key?('ansible_vault')
      Tiller::log.info('No Ansible vault configuration block for this environment')
      return
    end

    @ansible_vault_config.deep_merge!(Tiller::config['ansible_vault'])

    # Get the password
    if ENV.has_key?(@ansible_vault_config['vault_password_env'])
      Tiller::log.debug("#{self} : Using password from environment variable #{@ansible_vault_config['vault_password_env']}")
      @password = ENV[@ansible_vault_config['vault_password_env']]
    elsif @ansible_vault_config.has_key?('vault_password')
      Tiller::log.debug('#{self} : Using password from configuration block')
      @password = @ansible_vault_config['vault_password']
    elsif @ansible_vault_config.has_key?('vault_password_file')
      Tiller::log.debug("#{self} : Using password from file #{@ansible_vault_config['vault_password_file']}")
      @password = File.read(@ansible_vault_config['vault_password_file'])
    else
      raise('No Ansible Vault password provided')
    end

    # Open and decrypt the vault
    begin
      contents = Ansible::Vault.read(path: @ansible_vault_config['vault_file'], password: @password)
      @ansible_vault = YAML.load(contents)
    rescue Psych::SyntaxError
      raise('ERROR : Decrypted Ansible Vault file is not valid YAML')
    rescue Errno::ENOENT
      raise("Could not open Ansible Vault file #{@ansible_vault_config['vault_file']}")
    end


  end


  def global_values
    return {} unless Tiller::config.has_key?('ansible_vault')
    @ansible_vault
  end

end