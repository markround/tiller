# Needed as the old version of OpenSSL on Travis-CI doesn't by default support the ciphers used by Hashicorp.
def hashicorp_download(url, target)
  uri   = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.ssl_version = :SSLv23
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  open(target, "wb") do |file|
    file.write(response.body)
  end
end