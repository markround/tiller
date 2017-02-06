require 'tiller/json'
require 'tiller/api/handlers/404'

def handle_globals(api_version, tiller_api_hash)
  warning_json = { deprecation_warning: 'The v1 Tiller API is deprecated. Expect this endpoint to be removed in future versions.' }
  case api_version
    when 'v1'
      {
          :content => dump_json(tiller_api_hash['global_values'].merge(warning_json)),
          :status => '200 OK'
      }
    else
      handle_404
  end
end
