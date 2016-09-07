require 'pp'
require 'vault'
require 'tiller/templatesource'
require 'tiller/vault.rb'

class VaultTemplateSource < Tiller::TemplateSource

  include Tiller::VaultCommon

  def templates
    return [] unless Tiller::config.has_key?('vault')
    path = interpolate("#{@vault_config['templates']}")
    Tiller::log.debug("#{self} : Fetching templates from #{path}")

    templates = nil

    Vault.with_retries(Vault::HTTPConnectionError, Vault::HTTPError) do |attempt, e|
        Tiller::log.warn("#{self} : Received exception #{e} from Vault") if e
        templates = Vault.logical.list(path)
    end

    if templates.is_a? Array
      templates
    else
      Tiller::log.warn("Consul : No templates could be fetched from #{path}")
      []
    end
  end

  def template(template_name)
    path = interpolate("#{@vault_config['templates']}")

    Vault.with_retries(Vault::HTTPConnectionError, Vault::HTTPError) do |attempt, e|
        Tiller::log.warn("#{self} : Received exception #{e} from Vault") if e
        Vault.logical.read(File.absolute_path(template_name,path)).data[:content]
    end

  end


end
