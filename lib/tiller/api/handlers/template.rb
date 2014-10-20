require 'json'
require 'tiller/api/handlers/404'

def handle_template(api_version, tiller_api_hash, template)
  case api_version
    when 'v1'
      if tiller_api_hash['templates'].has_key?(template)
        {
            :content => tiller_api_hash['templates'][template].to_json,
            :status => '200 OK'
        }
      else
        {
            :content => '{ "error" : "template not found" }',
            :status => '404 Not Found'
        }
      end
  end
end