require 'tiller/logger'

# Tiller template source base class
module Tiller
  # Subclasses provide templates (an array), and individual template contents
  # (a string containing ERB data)
  class TemplateSource

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
  end
end
