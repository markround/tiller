module Tiller

  # Simple KV implementation to facilitate passing 'private' data between datasources and helpers

  class Kv
    @@kv = {}

    def self.set(path, value, options={})
      ns = options[:namespace] || 'tiller'
      hash = path.sub(/^\//, '').split('/').reverse.inject(value) { |h, s|  {s => h}  }
      Tiller::log.debug("#{self} : Setting [#{ns}]#{path} = #{value}")
      @@kv[ns]=hash
    end

    def self.get(path, options={})
      ns = options[:namespace] || 'tiller'
      value = path.sub(/^\//, '').split('/').inject(@@kv[ns]) { |h,v| h[v] }
      if value == nil
        Tiller::log.warn("#{self} : Request for non-existent key [#{ns}]#{path}")
      end
      value
    end

  end
end

