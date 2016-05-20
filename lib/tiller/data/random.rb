def plugin_meta
  {
      id: 'com.markround.tiller.data.random',
      title: 'Random data',
      description: "Simple wrapper to provide random values to your templates.",
      documentation: <<_END_DOCUMENTATION
# Random Plugin
If you add `  - random` to your list of data sources in `common.yaml`, you'll be able to use randomly-generated values and strings in your templates, e.g. `<%= random_uuid %>`. This may be useful for generating random UUIDs, server IDs and so on. An example hash with demonstration values is as follows :

	{"random_base64"=>"nubFDEz2MWlIiJKUOQ+Ttw==",
	 "random_hex"=>"550de401ef69d92b250ce379e5a5957c",
	 "random_bytes"=>"3\xC8fS\x11`\\W\x00IF\x95\x9F8.\xA7",
	 "random_number_10"=>8,
	 "random_number_100"=>71,
	 "random_number_1000"=>154,
	 "random_urlsafe_base64"=>"MU9UP8lEOVA3Nsb0OURkrw",
	 "random_uuid"=>"147acac8-7229-44af-80c1-246cf08910f5"}
_END_DOCUMENTATION
  }
end

require 'tiller/datasource'
require 'securerandom'

class RandomDataSource < Tiller::DataSource
  def global_values
    {
      'random_base64' => SecureRandom.base64,
      'random_hex' => SecureRandom.hex,
      'random_bytes' => SecureRandom.random_bytes,
      'random_number_10' => SecureRandom.random_number(10),
      'random_number_100' => SecureRandom.random_number(100),
      'random_number_1000' => SecureRandom.random_number(1000),
      'random_urlsafe_base64' => SecureRandom.urlsafe_base64,
      'random_uuid' => SecureRandom.uuid
    }
  end
end
