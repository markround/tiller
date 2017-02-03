module Tiller

  # Simple KV implementation to facilitate passing 'private' data between datasources and helpers

  class Kv
    @@kv = {}

    def self.set(path, value, options={})
      ns = options[:namespace] || 'tiller'
      hash = path.sub(/^\//, '').split('/').reverse.inject(value) { |h, s|  {s => h}  }
      Tiller::log.debug("KV: Setting [#{ns}]#{path} = #{value}")
      @@kv[ns]=hash
    end

    def self.get(path, options={})
      ns = options[:namespace] || 'tiller'
      path.sub(/^\//, '').split('/').inject(@@kv[ns]) { |h,v| h[v] }
    end

  end
end

