# This is a "dummy" datasource for Tiller. All it does is provide a single global and local value,
# And shows how you can provide a hash of target values to configure where templates are written.

class DummyDataSource < Tiller::DataSource

  def initialize(config)
    super
    @global_values = {
        'dummy_global' => 'dummy global replacement text'
    }
  end

  def values(template_name)
    { 'dummy' => 'dummy replacement text' }
  end

  # Dummy values, useful for testing. Will just result in the template being built and written to /tmp/dummy.
  # Remember that perms must be in octal (no quotes).
  # Note that as you have the environment name in the @@config hash, you can always return different values
  # for different environments.
  def target_values(template_name)
    {
        'target'  => "/tmp/dummy/#{template_name}",
        'user'    => 'root',
        'group'   => 'root',
        'perms'   => 0644
    }
  end

end
