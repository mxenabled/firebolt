module Firebolt
  class Cache
    def self.cache_key(key_suffix)
      "#{::Firebolt.config.namespace}.#{key_suffix}"
    end

    def self.cache_key_with_salt(key_suffix, salt)
      "#{::Firebolt.config.namespace}.#{salt}.#{key_suffix}"
    end

    def self.fetch(suffix, options = nil, &block)
      key = self.salted_cache_key(suffix)
      return nil if key.nil?

      ::Firebolt.config.cache.fetch(key, options, &block)
    end

    def self.keys_key
      cache_key(:keys)
    end

    def self.read(key_suffix, options = nil)
      key = self.salted_cache_key(key_suffix)
      return nil if key.nil?

      ::Firebolt.config.cache.read(key, options)
    end

    def self.reset_salt!(new_salt)
      ::Firebolt.config.cache.write(self.salt_key, new_salt)
    end

    def self.salt
      ::Firebolt.config.cache.read(self.salt_key)
    end

    def self.salt_key
      cache_key(:salt)
    end

    def self.salted_cache_key(key_suffix)
      salt = self.salt
      return nil if salt.nil?

      self.cache_key_with_salt(key_suffix, salt)
    end
  end
end
