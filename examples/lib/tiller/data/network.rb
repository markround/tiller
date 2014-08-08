require 'socket'

# This is a quick example of a global datasource for Tiller. It shows how you might provide some basic
# network-related information to your templates. It's a super quick and hacky, but serves as a useful example.
# You can then do things like <%= fqdn %> or <%= ipv4_addresses[0][3] %> in your templates.

class NetworkDataSource < Tiller::DataSource

  def global_values
    # Note, these rely on DNS being available and configured correctly!
    {
        'fqdn'            =>  Socket.gethostbyname(Socket.gethostname).first,
        'ipv4_addresses'  =>  Socket.getaddrinfo(Socket.gethostbyname(Socket.gethostname).first, nil, :INET)
    }
  end

end
