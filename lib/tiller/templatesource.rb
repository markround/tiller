require 'tiller/logger'

# Tiller template source base class
module Tiller
  # Subclasses provide templates (an array), and individual template contents
  # (a string containing ERB data)
  class TemplateSource

    # Every plugin gets this hash, which is the full parsed config
    @config = {}

    def initialize(config)
      @config = config
      @log = Tiller::Logger.new(config)
      setup
    end

    # This is where any post-initialisation logic happens
    # (connecting to a database etc.)
    def setup
    end

    def templates
      {}
    end

    def template
      ""
    end

    def ping
      'ping!' + @config.to_s
    end
  end
end
