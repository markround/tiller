require 'tiller/util'

# Tiller template source base class
module Tiller
  # Subclasses provide templates (an array), and individual template contents
  # (a string containing ERB data)
  class TemplateSource

    include ClassLevelInheritableAttributes
    inheritable_attributes :plugin_api_versions
    @plugin_api_versions = [ 1 ]

    def initialize
      setup
    end

    # This is where any post-initialisation logic happens
    # (connecting to a database etc.)
    def setup
    end

    def templates
      []
    end

    def template(_template_name)
      ""
    end

    def ping
      'ping!' + Tiller::config.to_s
    end

    def deprecated
      Tiller::log.warn("#{self} : This plugin is deprecated and will be removed in a future release")
    end
    
  end
end
