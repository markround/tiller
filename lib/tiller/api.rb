require 'json'
require 'socket'
require 'tiller/api/handlers/404'
require 'tiller/api/handlers/ping'
require 'tiller/api/handlers/config'


API_VERSION=1
API_PORT=6275

# The following is a VERY simple HTTP API, used for querying the status of Tiller
# after it has generated templates and forked a child process.

def tiller_api(tiller_api_hash)
  api_port = tiller_api_hash['config']['api_port'] ?
      tiller_api_hash['config']['api_port'] : API_PORT

  puts "Tiller API starting on port #{api_port}" if tiller_api_hash['config'][:verbose]

  server = TCPServer.new('localhost', api_port)

  loop do
    socket = server.accept
    request = socket.gets
    (method, uri, http_version) = request.split

    if uri =~ /^\/v([0-9]+)\//
      api_version = uri.split('/')[1]
    end

    # Defaults
    response = handle_404

    # Routing
    case method
      when 'GET'
        case uri
          when '/ping'
            response = handle_ping
          when /\/v([0-9]+)\/config/
            response = handle_config(api_version, tiller_api_hash)
        end
    end

    # Response
    socket.print "HTTP/1.1 #{response[:status]}\r\n" +
                     "Content-Type: application/json\r\n" +
                     "Server: Tiller #{VERSION} / API v#{API_VERSION}\r\n"
                     "Content-Length: #{response[:content].bytesize}\r\n" +
                     "Connection: close\r\n"
    socket.print "\r\n"
    socket.print response[:content]
    socket.close
  end
end




