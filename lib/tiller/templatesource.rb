# Tiller template source base class
# Subclasses provide templates (an array), and individual template contents (a string containing ERB data)

module Tiller
  class TemplateSource

    # All subclasses get this, which is a hash containing tiller_base, tiller_lib and environment.
    @@config = Array.new

    def initialize(config)
      @@config = config
    end

    # This is where any post-initialisation logic happens (connecting to a database etc.)
    def setup
    end

    def templates
      Hash.new
    end

    def template
      String.new
    end

    def ping
      "ping!" + @@config.to_s
    end
  end
end
