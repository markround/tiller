# Tiller data source base class.
#
# Subclasses provide global_values and/or values (things local to a specific template) and target_values (meta data
# about a template, e.g. target location, permissions, owner and so on)

module Tiller
  class DataSource

    # All subclasses get this, which is a hash containing tiller_base, tiller_lib and environment.
    @@config = Array.new

    def initialize(config)
      @@config = config
      @global_values = Hash.new
    end

    attr_reader :global_values

    # We should always return a hash; if we have no data for the given template, just return an empty hash.
    def values(template_name)
      Hash.new
    end

    # This should provide a hash similar to this example :
    #{
    #    'target'  => "/tmp/#{template_name}",
    #    'user'    => 'root',
    #    'group'   => 'root',
    #    'perms'   => '0644'
    #}
    # Again, we should always return a hash; if we have no data for the given template, just return an empty hash.
    def target_values(template_name)
      Hash.new
    end

    def ping
      "ping!" + @@config.to_s
    end

  end
end
