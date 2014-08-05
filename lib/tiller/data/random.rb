# Random datasource for Tiller. Provides Base64, UUID and other useful random strings

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
