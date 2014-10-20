def handle_ping
  {
      :content => "{ \"ping\": \"Tiller API v#{API_VERSION} OK\" }",
      :status => '200 OK'
  }
end